import argparse
import os
import time

from vyservices.vy_utils import get_logger, LOGGER_NAME

from reports.pmr_alc import main

logger = get_logger(LOGGER_NAME)

if __name__ == '__main__':

    # Init ArgumentParser
    parser = argparse.ArgumentParser()
    parser.add_argument('-sd', '--start_date', type=str, help='The date format is %Y%m%d eg 20220115',
                        required=True)

    parser.add_argument('-ed', '--end_date', type=str, help='The date format is %Y%m%d eg 20220115',
                        required=True)

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
