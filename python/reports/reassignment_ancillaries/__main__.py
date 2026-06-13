import os
import time

from vyservices.vy_utils import get_logger, LOGGER_NAME

from reports.reassignment_ancillaries import main

logger = get_logger(LOGGER_NAME)
if __name__ == '__main__':

    try:
        t1 = time.time()
        logger.info(f"ENV: env:{os.getenv('env')}, local:{os.getenv('local')}, aws_profile:{os.getenv('AWS_PROFILE')}")

        main()

        logger.info(f"Elapsed Time (seconds): {round(time.time() - t1, 4)}")
        logger.info(f"Process {__name__} has been finished successfully.")

    except Exception as ex:
        logger.error(f"ERROR: {ex}")
        raise
