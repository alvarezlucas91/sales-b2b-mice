import argparse
import os
import time
from vyservices import vy_utils
from vyservices.vy_utils import LOGGER_NAME

from reports.credito_individual import main

logger = vy_utils.get_logger(LOGGER_NAME)

if __name__ == '__main__':
    try:
        # Init ArgumentParser
        parser = argparse.ArgumentParser()
        parser.add_argument('-bd', '--booking_date', type=str, help='The date format is %Y%m%d eg 20220115',
                            required=True)
        args = parser.parse_args()

        t1 = time.time()

        logger.info('START - Report credito_indivivual monitoring process')
        logger.info(f"ENV: env:{os.getenv('env')}, local:{os.getenv('local')}, aws_profile:{os.getenv('AWS_PROFILE')}")

        main(**args.__dict__)

        logger.info(f"Elapsed Time (seconds): {round(time.time() - t1, 4)}")
        logger.info(f"The process {__name__} has been finished successfully.")

    except Exception as ex:
        logger.error(f"ERROR: {ex}")
        raise
