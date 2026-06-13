import json
import requests
from vyservices.vy_secret import get_secret_key_value, logger
from vyservices.vy_utils import get_data_file_path


def get_sharepoint_token() -> str:
    """
    :return: return token for connect to sharepoint api
    """
    try:
        logger.info("START TOKEN CREATION")
        url_token = "https://login.microsoftonline.com/{}/oauth2/v2.0/token".format(
            get_secret_key_value('SHAREPOINT_TENANT_ID'))
        data = {'grant_type': 'client_credentials',
                'client_id': get_secret_key_value('SHAREPOINT_CLIENT_ID'),
                'client_secret': get_secret_key_value('SHAREPOINT_CLIENT_SECRET'),
                'scope': 'https://graph.microsoft.com/.default'}
        response = requests.post(url=url_token, data=data)
        # Con esta función, si el status no es 200, mostrará error
        response.raise_for_status()
        res = response.json()
        token = res.get('access_token')
        if token:
            logger.info("TOKEN CREATED SUCCESSFULLY")
            return token
        else:
            raise "EMPTY TOKEN"
    except Exception as ex:
        logger.error(f"ERROR: {get_sharepoint_token.__name__} - {ex}")
        raise


def upload_file_sharepoint(filename, token, path_file) -> None:
    """
    :param path_file: Sharepoint path
    :param filename: Name of the file that we want to upload
    :param token: Token necessary for connect to sharepoint api
    """
    try:
        logger.info("START UPLOAD FILE TO SHAREPOINT ")
        path_id = get_secret_key_value('SHAREPOINT_PATH_ID')
        drive_id = get_secret_key_value('SHAREPOINT_DRIVE_ID')
        upload_url = f'https://graph.microsoft.com/v1.0/sites/{path_id}/drives/{drive_id}/items/root:/{path_file}/{filename}:/content'
        headers = {'Authorization': 'Bearer ' + token}
        with open(get_data_file_path(filename), 'rb') as f:
            file_res = requests.put(upload_url, f, headers=headers)
        if file_res.ok:
            logger.info("FILE LOAD SUCCESSFULLY INTO SHAREPOINT")
        else:
            logger.info("ERROR LOAD FILE INTO SHAREPOINT")
    except Exception as ex:
        logger.error(f"ERROR: {upload_file_sharepoint.__name__} - {ex}")
