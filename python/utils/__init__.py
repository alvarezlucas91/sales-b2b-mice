import os
from vysession.vy_session import AutoRefreshSession
from pathlib import Path

PROJECT_PATH = Path(__file__).parents[2]

CONFIG_FOLDER = "config"
LOG_FOLDER = "log"
DATA_FOLDER = "data"
QUERY_FOLDER = "query"
JAR_FOLDER = "jar"
MAIL_FOLDER = "mail"

env = os.getenv("env")

if env is None:
    raise ValueError("env must be defined")

local = bool(os.getenv("local", False))

if local:
    AutoRefreshSession(
        #"arn:aws:iam::123456789012:role/commercial-salesb2b-mice-r"
        role_mode=False
    ).Session()


#   AUTOMATION CONFIGURATION

CONFIG_FILE = {'reports': {}, 'etl': {}}


def is_config_file(path: str, file, extension_format='cfg'):
    extension = file.split('.')[-1]
    return os.path.isfile(path) and extension == extension_format


def sub_config(keyword, path, files, dir_files):
    if is_config_file(path=os.path.join(path, files, dir_files), file=dir_files):
        if CONFIG_FILE.get(keyword).get(files) is None:
            CONFIG_FILE[keyword].update({f"{files}": {}})
        CONFIG_FILE[keyword][files].update({f"{dir_files[:-4]}": f"{keyword}/{files}/{dir_files}"})


def autoimport_configs_from(keyword: str) -> None:
    """
    @param keyword: The string of the folders that we want to add into CONFIG_FILE
    @return: Modify the CONFIG_FILE dictionary adding all the configurations
    """
    path = os.path.join(PROJECT_PATH, CONFIG_FOLDER, keyword)

    for files in os.listdir(path):
        if is_config_file(path=os.path.join(path, files), file=files):
            CONFIG_FILE[keyword].update({files[:-4]: f"{keyword}/{files}"})
        else:
            for dir_files in os.listdir(os.path.join(path, files)):
                sub_config(keyword=keyword, path=path, files=files, dir_files=dir_files)


# Import Config Files
autoimport_configs_from('reports')
autoimport_configs_from('etl')
