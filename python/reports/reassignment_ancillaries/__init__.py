import datetime
import logging
import os.path

import pandas as pd
from sqlalchemy import text, Connection
from vyservices.vy_sql import get_connection, execute_raw_query
from vyservices.vy_utils import get_query_file_path, format_file_with_ordered_params, get_data_file_path, LOGGER_NAME

from utils.email import send_mail
from utils.export_data import save_data_as_excel

# DATABASE
QUERY_PATH = 'reports/reassignment_ancillaries/'
SERVER_NAME = 'ODS'
USE_DB = 'Vueling_Navitaire'
FINAL_DB = 'Vueling_CALCODS.dbo.'

GENERATE_ALLOTMENTS_TABLE = FINAL_DB + 'stg_sales_report_reassignment_ancillaries_allotments'
GENERATE_CANCEL_FEES_TABLE = FINAL_DB + 'stg_sales_report_reassignment_ancillaries_cancel_fees'
GENERATE_ADD_FEES_TABLE = FINAL_DB + 'stg_sales_report_reassignment_ancillaries_add_fees'
GENERATE_RESULT_TABLE = FINAL_DB + 'stg_sales_report_reassignment_ancillaries_result'

# FORMAT FILES
DATE_FORMAT = "%Y%m%d"

FILENAME = f'report_reassignment_ancillaries_{datetime.date.today().strftime(format=DATE_FORMAT)}.xlsx'

# CONSTANTS
TABLES = [GENERATE_ALLOTMENTS_TABLE, GENERATE_CANCEL_FEES_TABLE, GENERATE_ADD_FEES_TABLE, GENERATE_RESULT_TABLE]

logger = logging.getLogger(LOGGER_NAME)


def main():
    conn = get_connection(server_name=SERVER_NAME, database=USE_DB)
    logger.info('Connection has been created successfully.')

    # Truncate STG Tables
    for table in TABLES:
        truncate(conn=conn, table=table)

    # Generate Data to STG Tables
    generate_allotments(conn=conn)
    generate_cancel_fees(conn=conn)
    generate_add_fees(conn=conn)
    generate_results(conn=conn)

    # Gather data
    df = gather_results(conn=conn)
    save_data_as_excel(data=df, filename=FILENAME)

    send_mail(attachments=[get_data_file_path(data_file=FILENAME)],
              secret_name='EMAIL_CONFIG_REPORT_REASSIGNMENT_ANCILLARIES')


def generate_allotments(conn: Connection) -> None:
    logger.info("Generate Allotments")
    query = format_file_with_ordered_params(
        get_query_file_path(os.path.join(QUERY_PATH, 'sql', 'generate_allotments.sql')),
        params=[GENERATE_ALLOTMENTS_TABLE])

    logger.info(query)
    conn.execute(text(query))
    conn.commit()


def generate_cancel_fees(conn: Connection) -> None:
    logger.info("Generate canceled fees")
    query = format_file_with_ordered_params(
        get_query_file_path(os.path.join(QUERY_PATH, 'sql', 'generate_cancel_fees.sql')),
        params=[GENERATE_CANCEL_FEES_TABLE, GENERATE_ALLOTMENTS_TABLE])

    logger.info(query)
    conn.execute(text(query))
    conn.commit()


def generate_add_fees(conn: Connection) -> None:
    logger.info("Generate added fees")
    query = format_file_with_ordered_params(
        get_query_file_path(os.path.join(QUERY_PATH, 'sql', 'generate_add_fees.sql')),
        params=[GENERATE_ADD_FEES_TABLE, GENERATE_CANCEL_FEES_TABLE])

    logger.info(query)
    conn.execute(text(query))
    conn.commit()


def generate_results(conn: Connection) -> None:
    logger.info("Generate final results")
    query = format_file_with_ordered_params(
        get_query_file_path(os.path.join(QUERY_PATH, 'sql', 'generate_results.sql')),
        params=[GENERATE_RESULT_TABLE, GENERATE_CANCEL_FEES_TABLE, GENERATE_ADD_FEES_TABLE])
    logger.info(query)
    conn.execute(text(query))
    conn.commit()


def gather_results(conn: Connection) -> pd.DataFrame:
    logger.info("Gather Results")
    query = format_file_with_ordered_params(
        get_query_file_path(os.path.join(QUERY_PATH, 'sql', 'gather_results.sql')),
        params=[GENERATE_RESULT_TABLE])

    return execute_raw_query(conn=conn, server_name=SERVER_NAME, query=query)


def truncate(conn: Connection, table: str) -> None:
    logger.info(f"The table {table} will be truncated.")
    query = format_file_with_ordered_params(
        get_query_file_path(os.path.join(QUERY_PATH, 'sql', 'truncate_table.sql')), params=[table])
    logger.info(query)
    conn.execute(text(query))
    conn.commit()
