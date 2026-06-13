from ftplib import FTP

from utils.gather_data import logger


def ftp_connect(ftp_host, ftp_pass, ftp_port, ftp_user) -> FTP:
    try:
        ftp_conn = FTP()
        ftp_conn.connect(host=ftp_host, port=int(ftp_port), timeout=60)
        ftp_conn.login(user=ftp_user, passwd=ftp_pass)
        logger.info(f'Connected to ftp')
        return ftp_conn
    except Exception as e:
        raise Exception(e, "FTP connection error")
