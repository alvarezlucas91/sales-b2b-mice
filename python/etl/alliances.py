import logging

import pandas as pd
from vyservices import vy_sql, vy_s3, vy_redshift
from vyservices.vy_utils import LOGGER_NAME, create_folder, get_data_file_path

from utils import CONFIG_FILE

logger = logging.getLogger(LOGGER_NAME)


def get_data(config_section: str, start_date: str, end_date: str) -> pd.DataFrame:
    """
    The functions gather the alliances from ODS source. In addition, we consider alliance the pnr that it is not
    operated and carrier by the same airline.
    e.g.  Carried By Vueling and Operated By Iberia

    @param config_section: str. Section that we want to execute
    @param start_date: str '%Y%m%d'. date that defines the start point to gather data
    @param end_date: str '%Y%m%d'. date that defines the end point to gather data
    @return: pd.DataFrame corresponding to the result of the query execution
    """

    try:
        df = vy_sql.execute_query(config_file=CONFIG_FILE.get('etl').get('alliances'),
                                  config_section=config_section,
                                  params=[start_date, end_date])

        logger.info(f'Data Gathered: {df.shape}, isEmpty: {df.empty}, columns: {df.columns.tolist()}')
        return df

    except Exception as ex:
        logger.error(f"ERROR: {get_data.__name__} - {ex}")
        raise


def save_to_s3(df: pd.DataFrame, tag: str) -> str:
    """
    The function store the data to S3 bucket.
    @param df: Dataframe that we want to save.
    @param tag: tag of the gathering data.
    @return str. The filename.
    """

    try:
        filename = f"{tag}.gzip"

        create_folder(get_data_file_path(''))
        df.to_csv(get_data_file_path(filename), compression='gzip', sep='|', index=False)

        vy_s3.copy_from_local_to_s3(config_file=CONFIG_FILE.get('etl').get('alliances'),
                                    config_section='UPLOAD_TO_S3_ALLIANCES', data_files=filename)
        return filename
    except Exception as ex:
        logger.error(f'ERROR: {save_to_s3.__name__} - {ex} ')
        raise


def save_to_redshift(filename: str) -> None:
    """
    The function store the data to S3 bucket.
    @param filename: str. String that identifies the file.
    @return: None
    """

    try:
        # {0}->TABLE_NAME, {1}->S3_PATH, {2}->AWS_ACCESS_KEY, {3}-> AWS_SECRET_ACCESS_KEY
        vy_redshift.copy_from_s3(config_file=CONFIG_FILE.get('etl').get('alliances'),
                                 config_section='COPY_FROM_S3',
                                 params=[filename], keep_conn=True)
    except Exception as ex:
        logger.error(f'ERROR: {save_to_redshift.__name__} - {ex} ')
        raise RuntimeError('The process of copying data to AWS Redshift failed.')


def load_data_to_stg(df: pd.DataFrame, tag: str) -> None:
    """
    Load data from local to S3 and S3 to Redshift.
    @param df: Dataframe that contains all the data gathered.
    @param tag: String that determinate the name of the output filename, composed by
    @return: None
    """
    filename = save_to_s3(df=df, tag=tag)

    if filename:
        save_to_redshift(filename=filename)
    else:
        raise FileNotFoundError


def truncate_stg_table() -> None:
    """
    Truncation the stage table
    @return: None
    """
    try:
        vy_redshift.execute_query(config_file=CONFIG_FILE.get('etl').get('alliances'),
                                  config_section='TRUNCATE_STG_CUST_ALLIANCES', keep_conn=True)
    except Exception as ex:
        logger.error(f'ERROR: {truncate_stg_table.__name__} - {ex} ')
        raise ex


def insert_data() -> None:
    """
    Insert data to final table
    @return: None
    """
    try:
        logger.info("Inserting data to final table salesb2b.cust_alliances")
        vy_redshift.execute_query(config_file=CONFIG_FILE.get('etl').get('alliances'),
                                  config_section='INSERT_DATA_TO_CUST_ALLIANCES')
        logger.info("The data have been inserted successfully.")
    except Exception as ex:
        logger.error(f'ERROR: {insert_data.__name__} - {ex} ')
        raise


def delete_existing_records():
    """
    Compare records from stage table and final table, also, it removes existing records from final table.
    @return: None
    """
    try:
        logger.info("Deleting existing records...")
        vy_redshift.execute_query(config_file=CONFIG_FILE.get('etl').get('alliances'),
                                  config_section='DELETE_EXISTING_RECORDS', keep_conn=True)
    except Exception as ex:
        logger.error(f'ERROR: {delete_existing_records.__name__} - {ex} ')
        raise


def main(task: str, start_date: str, end_date: str) -> None:
    """
    Main function that executes the gathering and loading part of the ETL.
    @param task: String that identifies the config section that the process will execute.
    @param start_date: String that represents the start point that the process will gather data.
    @param end_date: String that represents the end point that the process will gather data.
    @return: None
    """
    df = get_data(config_section=task, start_date=start_date, end_date=end_date)

    if not df.empty:
        truncate_stg_table()
        load_data_to_stg(df=df, tag=task)
        delete_existing_records()
        insert_data()
