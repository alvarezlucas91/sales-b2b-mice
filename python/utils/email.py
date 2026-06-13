import json
import logging

from vyservices import vy_secret, vy_smtp
from vyservices.vy_utils import LOGGER_NAME, get_data_file_path

logger = logging.getLogger(LOGGER_NAME)


def send_mail(attachments: list, secret_name: str, subject=None, body=None):
    """
    Send email attaching the correspondents files to the final users
    @param secret_name:
    @param body:
    @param subject:
    @param secret_name:
    @param attachments: filenames of the files that will be attached.
    @return:
    """
    config_str = vy_secret.get_secret_key_value(secret_name)
    mail_conf = json.loads(config_str)

    if subject:
        mail_conf.update({'subject': subject})

    if body:
        mail_conf.update({'body': body})

    mail_conf.update({"attachments": [get_data_file_path(i) for i in attachments]})
    logger.info(f'The email config was : {mail_conf}')
    try:
        vy_smtp.send_mail(**mail_conf)
        logger.info(f'SMTP - {send_mail.__name__}: The email has been sent successfully.')
    except Exception as ex:
        logger.error(f'SMTP:  {send_mail.__name__} - {ex}')
        raise
