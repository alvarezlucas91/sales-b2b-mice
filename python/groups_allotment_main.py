import argparse
import time
import os

from etl.groups_allotments import main
from vyservices.vy_utils import LOGGER_NAME, get_logger

logger = get_logger(LOGGER_NAME)

if __name__ == '__main__':
    # Init ArgumentParser
    parser = argparse.ArgumentParser()
    parser.add_argument('-sd', '--start_date', type=str, help='The date format is %Y%m%d eg 20220115',
                        required=True)
    parser.add_argument('-ed', '--end_date', type=str, help='The date format is %Y%m%d eg 20230523', required=True)
    args = parser.parse_args()

    try:
        t1 = time.time()
        logger.info(f"ENV: env:{os.getenv('env')}, local:{os.getenv('local')}, aws_profile:{os.getenv('AWS_PROFILE')}")
        logger.info(f'START: Group Allotment:  {args.__dict__}')
        main(**args.__dict__)
        logger.info(f'END: Group Allotments | Elapsed time (seconds): {round(time.time() - t1, 2)} ')

    except Exception as e:
        logger.error(f'ERROR: {e}')
        raise
