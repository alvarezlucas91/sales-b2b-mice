import logging

from sqlalchemy import text
from vyservices.vy_sql import get_connection
from vyservices.vy_utils import get_value_from_config, format_file_with_ordered_params, LOGGER_NAME, get_query_file_path

logger = logging.getLogger(LOGGER_NAME)


def execute_sql_query(config_file, config_section, params=None):
    query_file = get_value_from_config(config_file=config_file,
                                       config_section=config_section,
                                       config_key='sql_execute_query_path')

    server = get_value_from_config(config_file=config_file,
                                   config_section=config_section,
                                   config_key='sql_server')

    db = get_value_from_config(config_file=config_file,
                               config_section=config_section,
                               config_key='sql_database')

    if params is None:
        params = []
    try:
        query = format_file_with_ordered_params(get_query_file_path(query_file),
                                                params=params)
        conn = get_connection(server_name=server, database=db)
        logger.info(f"EXECUTE: {query}")
        conn.execute(text(query))
        conn.commit()
    except Exception as ex:
        conn.close()
        logger.error(f'ERROR: {execute_sql_query.__name__} - {ex} ')
        raise
    finally:
        conn.close()
