import logging

import pandas as pd
from vyservices import vy_sql, vy_redshift
from vyservices.vy_utils import LOGGER_NAME

logger = logging.getLogger(LOGGER_NAME)


def gather_data(config_file: str, config_section: str, params=None, source='onprem') -> pd.DataFrame:
    """
    @return: Return the dataframe with the data.
    """
    if params is None:
        params = []
    try:
        logger.info("START EXTRACT DATA")
        if source == 'onprem':
            df = vy_sql.execute_query(config_file=config_file,
                                      config_section=config_section,
                                      params=params)
        if source == 'redshift':
            df = vy_redshift.execute_query(config_file=config_file,
                                           config_section=config_section,
                                           params=params)

        logger.info(f'Data Gathered: {df.shape}, isEmpty: {df.empty}, columns: {df.columns.tolist()}')
        return df

    except Exception as ex:
        logger.error(f'ERROR: {gather_data.__name__} - {ex}')
        raise
