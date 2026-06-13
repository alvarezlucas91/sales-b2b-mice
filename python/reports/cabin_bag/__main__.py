from reports.cabin_bag import main
from vyservices.vy_utils import get_logger,LOGGER_NAME
logger = get_logger(LOGGER_NAME)
if __name__ == '__main__':
    try:
        main()
    except Exception as ex:
        logger.error(ex)
        raise