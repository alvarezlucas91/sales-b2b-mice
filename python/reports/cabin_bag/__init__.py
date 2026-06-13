import datetime
import logging

import pandas as pd
from sqlalchemy import text
from vyservices.vy_sql import get_connection, execute_raw_query
from vyservices.vy_utils import format_file_with_ordered_params, get_query_file_path, get_data_file_path, LOGGER_NAME, \
    create_folder

from utils.email import send_mail

SERVER_NAME = 'ODS'
DATABASE_NAME = 'Vueling_CALCODS'
QUERY_FOLDER = 'reports/cabin_bag/sql'

SECRET_NAME = 'EMAIL_CONFIG_REPORT_CABIN_BAG'
FILENAME_PATH = get_data_file_path(f"GUARANTEED_Cabin_Bag_{datetime.date.today().strftime('%Y%m%d')}.csv")

# EMAIL
SUBJECT_EMAIL = f"Guaranteed Cabin Bag report from {datetime.date.today().strftime('%Y-%m-%d')}"
BODY_EMAIL = f"""Hi to all,
Please, find attached the Guaranteed Cabin Bag report executed at {datetime.date.today().strftime('%Y-%m-%d')}.
If you have any doubt, please don't hesitate to contact us at data.sales@vueling.com.
Best regards."""

logger = logging.getLogger(LOGGER_NAME)


def main() -> None:
    create_folder(get_data_file_path(''))

    # aux flight
    logger.info("AUX TABLE: AUX_FLIGHTS_GUARANTEED_CABIN_BAG")
    execute_query('truncate/truncate_aux_flight_guaranteed_cabin_bag.sql', is_select=False, server_name=SERVER_NAME)
    execute_query(query_file='insert/insert_aux_flight_guaranteed_cabin_bag.sql', is_select=False,
                  server_name=SERVER_NAME)

    # insert data
    logger.info("AUX TABLE: AUX_GUARANTEED_CABIN_BAG ")
    execute_query('truncate/truncate_aux_guaranteed_cabin_bag.sql', is_select=False, server_name=SERVER_NAME)
    execute_query('insert/insert_aux_guaranteed_cabin_bag.sql', is_select=False, server_name=SERVER_NAME)

    # get data
    data = execute_query('get/get_cabin_bags.sql', server_name=SERVER_NAME)
    data.to_csv(get_data_file_path(FILENAME_PATH), index=False)

    # send data
    send_mail(subject=SUBJECT_EMAIL, body=BODY_EMAIL, attachments=[get_data_file_path(FILENAME_PATH)],
              secret_name=SECRET_NAME)


def execute_query(query_file: str, server_name: str, params=None, is_select=True) -> pd.DataFrame | None:
    if not params:
        params = []

    query = format_file_with_ordered_params(
        get_query_file_path(f"{QUERY_FOLDER}/{query_file}"), params)

    if is_select:
        return execute_raw_query(query=query, server_name=server_name)
    else:
        execute_query_without_output(server_name=server_name, query=query)


def execute_query_without_output(server_name: str, query: str) -> None:
    try:
        conn = get_connection(server_name=server_name)
        logger.info(f"EXECUTE: {query}")
        conn.execute(text(query))
        conn.commit()
        return
    except Exception as ex:
        logger.error(ex)
        raise
    finally:
        conn.close()
