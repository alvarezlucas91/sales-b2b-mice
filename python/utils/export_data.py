import logging
from pathlib import Path

import pandas as pd
import pyzipper
from vyservices.vy_utils import LOGGER_NAME, get_data_file_path, create_folder

logger = logging.getLogger(LOGGER_NAME)


def save_data_as_excel(data: pd.DataFrame, filename: str) -> None:
    """
    @param data:pd.Dataframe that contains the data.
    @param filename: filename to save the data.
    @return: Return True if the file has been created successfully.
    """
    try:
        create_folder(Path(get_data_file_path(filename)).parent)  # create folder if not exist
        file_path = get_data_file_path(data_file=filename)
        logger.info(f"START SAVING DATA IN {file_path}")
        data.to_excel(file_path, index=False)
        logger.info(f"The file {file_path} has been saved successfully.")

    except Exception as ex:
        logger.error(f"ERROR: {save_data_as_excel.__name__} - {ex}")
        raise


def save_data_as_csv(data: pd.DataFrame, filename: str) -> None:
    """
    @param data:pd.Dataframe that contains the data.
    @param filename: filename to save the data.
    @return: Return True if the file has been created successfully.
    """
    try:
        create_folder(Path(get_data_file_path(filename)).parent)  # create folder if not exist
        file_path = get_data_file_path(data_file=filename)
        logger.info(f"START SAVING DATA IN {file_path}")
        data.to_csv(file_path, index=False)
        logger.info(f"The file {file_path} has been saved successfully.")

    except Exception as ex:
        logger.error(f"ERROR: {save_data_as_excel.__name__} - {ex}")
        raise


def save_data_as_excel_sheets(data: list, filename: str, sheets_name: list) -> None:
    """

    @param filename: filename to save the data.
    @return: Return True if the file has been created successfully.
    @param data: List of dataframe
    @param sheets_name: Sheet names
    """
    try:
        create_folder(Path(get_data_file_path(filename)).parent)  # create folder if not exist
        file_path = get_data_file_path(data_file=filename)
        writer = pd.ExcelWriter(file_path)
        logger.info(f"START SAVING DATA IN {file_path}")

        for i, df in enumerate(data):
            df.to_excel(writer, sheet_name=sheets_name[i], index=False)

        writer.close()
        logger.info(f"The file {file_path} has been saved successfully.")

    except Exception as ex:
        logger.error(f"ERROR: {save_data_as_excel.__name__} - {ex}")
        raise


def compress_file_as_zip(filename: str, password: str = None) -> None:
    """
    @param filename: Name of the file to save the data.
    @param password: Password for the report's zip.
    @return: Returns True if the file has been created successfully.
    """

    try:
        extension = filename.split('.')[-1]
        file_path = get_data_file_path(filename)
        zip_path = file_path.replace(extension, 'zip')

        if password:
            with pyzipper.AESZipFile(zip_path, 'w',
                                     compression=pyzipper.ZIP_LZMA,
                                     encryption=pyzipper.WZ_AES) as zf:
                zf.setpassword(password.encode())
                zf.write(file_path, filename)
        else:
            with pyzipper.ZipFile(zip_path, 'w') as zf:
                zf.write(file_path, filename)

        logger.info(f"End Zip file {zip_path}")
    except Exception as ex:
        logger.error(f"ERROR: {compress_file_as_zip.__name__} - {ex}")
        raise
