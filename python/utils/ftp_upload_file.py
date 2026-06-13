from vyservices.vy_utils import get_data_file_path
from utils.export_data import save_data_as_excel, save_data_as_csv
from utils.gather_data import gather_data, logger


def ftp_upload_file(ftp, config_file, config_section, filename) -> None:
    try:
        df_diario = gather_data(config_file=config_file,
                                config_section=config_section)
        save_data_as_csv(data=df_diario, filename=filename)
        with open(get_data_file_path(filename), 'rb') as infile:
            logger.info(f'Uploading {filename} to ftp')
            ftp.storbinary(f'STOR {filename}', infile)
            logger.info(f'Uploaded {filename} to ftp')
        ftp.quit()
    except Exception as e:
        raise Exception(e, f'No se ha podido subir el archivo {filename} al ftp')
