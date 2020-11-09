import pathlib
import mara_db.postgresql
from facebook_ads_performance_pipeline import config

from mara_pipelines.commands.files import ReadSQLite
from mara_pipelines.commands.sql import ExecuteSQL
from mara_pipelines.parallel_tasks.files import ReadMode, ParallelReadSqlite
from mara_pipelines.parallel_tasks.sql import ParallelExecuteSQL
from mara_pipelines.pipelines import Pipeline, Task
from mara_pipelines.config import default_db_alias

pipeline = Pipeline(
    id="facebook",
    description="Processes the data downloaded from the FacebookAds API",
    base_path=pathlib.Path(__file__).parent,
    labels={"Schema": "fb_dim"})

pipeline.add_initial(
    Task(
        id="initialize_schemas",
        description="Recreates the tmp and dim_next schemas",
        commands=[
            ExecuteSQL(sql_statement="DROP SCHEMA IF EXISTS fb_dim_next CASCADE; CREATE SCHEMA fb_dim_next;"),
            ExecuteSQL(sql_file_name="create_data_schema.sql", echo_queries=False,
                       file_dependencies=["create_data_schema.sql"]),
            ExecuteSQL(sql_file_name="recreate_schemas.sql", echo_queries=False)
        ]))

pipeline.add(
    Task(
        id="read_campaign_structure",
        description="Loads the adwords campaign structure",
        commands=[
            ExecuteSQL(sql_file_name='create_campaign_structure_data_table.sql', echo_queries=False),
            ReadSQLite(sqlite_file_name='facebook-account-structure-{}.sqlite3'.format(config.input_file_version()),
                       sql_file_name='read_campaign_structure.sql',
                       target_table='fb_data.campaign_structure')]))

pipeline.add(
    ParallelReadSqlite(
        id="read_ad_performance",
        description="Loads ad performance data from json files",
        file_pattern="*/*/*/facebook/ad-performance-*-{}.sqlite3".format(config.input_file_version()),
        read_mode=ReadMode.ONLY_CHANGED,
        sql_file_name='read_ad_performance.sql',
        target_table="fb_data.ad_performance",
        date_regex="^(?P<year>\d{4})\/(?P<month>\d{2})\/(?P<day>\d{2})/",
        file_dependencies=['create_ad_performance_data_table.sql'],
        commands_before=[
            ExecuteSQL(sql_file_name="create_ad_performance_data_table.sql", echo_queries=False,
                       file_dependencies=['create_ad_performance_data_table.sql'])
        ],
        commands_after=[
            ExecuteSQL(sql_statement='SELECT fb_data.upsert_ad_performance()')
        ]))

pipeline.add(
    Task(
        id="preprocess_ad",
        description="Creates the different ad dimensions",
        commands=[
            ExecuteSQL(sql_file_name="preprocess_ad.sql")
        ]),
    ["read_campaign_structure", "read_ad_performance"])

pipeline.add(
    Task(
        id="transform_ad",
        description="Creates the ad dimension table",
        commands=[
            ExecuteSQL(sql_file_name="transform_ad.sql")
        ]),
    ["preprocess_ad"])


def index_ad_parameters():
    with mara_db.postgresql.postgres_cursor_context(default_db_alias()) as cursor:
        cursor.execute('''select util.get_columns('fb_dim_next', 'ad', '%_name');''')
        return cursor.fetchall()


pipeline.add(
    ParallelExecuteSQL(
        id="index_ad",
        description="Adds indexes to all columns of the ad dimension",
        sql_statement='''SELECT util.add_index('fb_dim_next', 'ad', column_names:=ARRAY[''@@param_1@@'']);''',
        parameter_function=index_ad_parameters,
        parameter_placeholders=["'@@param_1@@'"]),
    ["transform_ad"])

pipeline.add(
    Task(
        id="transform_ad_performance",
        description="Creates the fact table of the facebook cube",
        commands=[
            ExecuteSQL(sql_file_name="transform_ad_performance.sql")
        ]),
    ["read_ad_performance"])


def index_ad_performance_parameters():
    with mara_db.postgresql.postgres_cursor_context(default_db_alias()) as cursor:
        cursor.execute('''SELECT util.get_columns('fb_dim_next', 'ad_performance', '%_fk');''')
        return cursor.fetchall()


pipeline.add(
    ParallelExecuteSQL(
        id="index_ad_performance",
        description="Adds indexes to all fk columns of the ad performance fact table",
        sql_statement='''SELECT util.add_index('fb_dim_next', 'ad_performance',column_names := ARRAY [''@@param_1@@'']);''',
        parameter_function=index_ad_performance_parameters,
        parameter_placeholders=["'@@param_1@@'"]),
    ["transform_ad_performance"])

pipeline.add(
    Task(
        id="transform_ad_attribute",
        description="Creates the ad_attribute dimension table",
        commands=[
            ExecuteSQL(sql_file_name="transform_ad_attribute.sql")
        ]),
    ["preprocess_ad"])

pipeline.add_final(
    Task(
        id="replace_dim_schema",
        description="Replaces the current dim schema with the contents of dim_next",
        commands=[
            ExecuteSQL(sql_statement="SELECT fb_tmp.constrain_ad_performance();"),
            ExecuteSQL(sql_statement="SELECT fb_tmp.constrain_ad_attribute_mapping();"),
            ExecuteSQL(sql_statement="SELECT util.replace_schema('fb_dim','fb_dim_next');")
        ]))
