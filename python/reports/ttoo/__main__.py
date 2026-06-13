import argparse
import os
import time

from vyservices import vy_secret
from vyservices.vy_utils import get_logger, LOGGER_NAME

from reports.ttoo import main

logger = get_logger(LOGGER_NAME)

if __name__ == '__main__':
    # Cogemos los argumentos del dag
    parser = argparse.ArgumentParser()
    parser.add_argument('-i', '--num_iata', required=True, type=str, help='Number of iata')
    parser.add_argument('-n', '--nom_iata', required=True, type=str, help='Iata name')
    parser.add_argument('-td', '--today_date', required=True, type=str, help='Today date')
    args = parser.parse_args()
    try:
        t1 = time.time()
        logger.info(f"ENV: env:{os.getenv('env')}, local:{os.getenv('local')}, aws_profile:{os.getenv('AWS_PROFILE')}")
        main(**args.__dict__)
        logger.info(f"Elapsed Time (seconds): {round(time.time() - t1, 4)}")
        logger.info(f"Process {__name__} has been finished successfully.")
    except Exception as ex:
        logger.error(f"ERROR: {ex}")
        raise
