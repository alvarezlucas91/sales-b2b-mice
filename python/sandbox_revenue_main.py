import os
import time

from vyservices.vy_utils import LOGGER_NAME, get_logger

from etl.sandbox_revenue import main

logger = get_logger(LOGGER_NAME)

if __name__ == '__main__':

    try:
        t1 = time.time()
        logger.info(f"ENV: env:{os.getenv('env')}, local:{os.getenv('local')}, aws_profile:{os.getenv('AWS_PROFILE')}")
        logger.info('START: Copy Data to Sandbox Revenue')

        main()

        logger.info(f'END: Copy Data to Sandbox Revenue | Elapsed time (seconds): {round(time.time() - t1, 2)} ')

    except Exception as e:
        logger.error(f'ERROR: {e}')
        raise
