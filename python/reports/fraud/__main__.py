import argparse
import datetime
import os
import time

from vyservices.vy_utils import get_logger, LOGGER_NAME

from reports.fraud import main

logger = get_logger(LOGGER_NAME)

if __name__ == '__main__':
    try:
        t1 = time.time()
        logger.info(f"ENV: env:{os.getenv('env')}, local:{os.getenv('local')}, aws_profile:{os.getenv('AWS_PROFILE')}")
        parser = argparse.ArgumentParser()
        parser.add_argument('-sd', '--start_date', required=True, type=str,
                            default=datetime.date(year=2024, month=1, day=1))
        parser.add_argument('-ed', '--end_date', required=True, type=str, default=datetime.date.today())
        args = parser.parse_args()

        main(**args.__dict__)

        logger.info(f"Elapsed Time (seconds): {round(time.time() - t1, 4)}")
        logger.info(f"Process {__name__} has been finished successfully.")

    except Exception as ex:
        logger.error(f"ERROR: {ex}")
        raise
