from setuptools import setup, find_packages

setup(
    name='facebook-ads-performance-pipeline',
    version='1.0.1',
    description="A data integration pipeline that imports downloaded Facebook Ads performance data into a data warehouse",

    install_requires=[
        'facebook-ads-performance-downloader>=2.0.0',
        'mara-etl-tools>=1.1.0',
        'mara-pipelines>=3.1.0',
    ],

    dependency_links=[
        'git+https://github.com/mara/facebook-ads-performance-downloader.git@2.0.0#egg=facebook-ads-performance-downloader-2.0.0',
        'git+https://github.com/mara/mara-etl-tools.git@1.1.0#egg=mara-etl-tools-1.1.0',
        'git+https://github.com/mara/mara-pipelines.git@3.1.1#egg=mara-pipelines-3.1.1'
    ],

    packages=find_packages(),

    author='Mara contributors',
    license='MIT'
)
