import datetime
import os
import time

from vyservices.vy_utils import get_logger, LOGGER_NAME

from reports.codeshare_bookings import main

logger = get_logger(LOGGER_NAME)

if __name__ == '__main__':
    try:
        t1 = time.time()
        logger.info(f"ENV: env:{os.getenv('env')}, local:{os.getenv('local')}, aws_profile:{os.getenv('AWS_PROFILE')}")

        start_date = datetime.date.today() - datetime.timedelta(days=90)
        end_date = datetime.date.today()

        main(start_date=start_date, end_date=end_date)

        logger.info(f"Elapsed Time (seconds): {round(time.time() - t1, 4)}")
        logger.info(f"Process {__name__} has been finished successfully.")

    except Exception as ex:
        logger.error(f"ERROR: {ex}")
        raise
