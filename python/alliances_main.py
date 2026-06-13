import os
import time

from etl.alliances import main
import argparse
from vyservices.vy_utils import LOGGER_NAME, get_logger

logger = get_logger(LOGGER_NAME)

if __name__ == '__main__':
    logger.info(f"ENV: env:{os.getenv('env')}, local:{os.getenv('local')}, aws_profile:{os.getenv('AWS_PROFILE')}")

    # Init ArgumentParser
    parser = argparse.ArgumentParser()
    parser.add_argument('-sd', '--start_date', type=str, help='The date format is %Y%m%d eg 20220115', required=True)
    parser.add_argument('-ed', '--end_date', type=str, help='The date format is %Y%m%d eg 20230523', required=True)
    parser.add_argument('-t', '--task', type=str, choices=['GET_ALLIANCES_BY_SEGMENT', 'GET_ALLIANCES_BY_FLIGHT'],
                        help='Task that we want to execute',
                        required=True)
    args = parser.parse_args()

    try:
        t1 = time.time()
        logger.info(f'START: Alliances with the arguments {args.__dict__}')
        main(**args.__dict__)
        logger.info(f'END: Alliances | Elapsed time (seconds): {round(time.time() - t1, 2)}')

    except Exception as e:
        logger.error(f'ERROR: {e}')
        raise
