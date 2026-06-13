import logging

import pandas as pd
from vyservices import vy_sql, vy_s3, vy_redshift
from vyservices.vy_utils import LOGGER_NAME, create_folder, get_data_file_path

from utils import CONFIG_FILE
from utils.vy_sql_custom import execute_sql_query

logger = logging.getLogger(LOGGER_NAME)


def not_exist(df1: pd.DataFrame, df2: pd.DataFrame) -> pd.DataFrame:
    """
    Find rows that df1 not in df2.
    @param df1: pd.Dataframe:
    @param df2: pd.Dataframe: Dataframe to compare
    @return: DataFrame corresponding to the result set of the query execution
    """

    df_all = df1.merge(df2.drop_duplicates(), how='left', on=['at_cd_allotment_name', 'id_inventory_leg'],
                       indicator=True,
                       suffixes=('', '_DROP'))

    df_not_exist = df_all[df_all['_merge'] == 'left_only']

    return df_not_exist[df1.columns]


def get_sql_cancel_for_move_gral() -> pd.DataFrame:
    try:
        # Generate table Staging
        execute_sql_query(config_file=CONFIG_FILE.get('etl').get('group_allotment'),
                          config_section='LOAD_STG_CANCEL_ALLOTMENTS')

        # We recover the canceled ones that have remained pending
        return vy_sql.execute_query(config_file=CONFIG_FILE.get('etl').get('group_allotment'),
                                    config_section='GET_SQL_CANCEL_MOVE')

    except Exception as ex:
        logger.error(f'ERROR: {get_sql_cancel_for_move_gral.__name__} - {ex}')
        raise


def get_cancelled() -> pd.DataFrame:
    """
    @return: pd.Dataframe: It returns a dataframe with all the group allotments cancelled.
    """
    try:

        df_cancel = pd.DataFrame()

        logger.info(f'Start: {get_cancelled.__name__}')
        # We recover the canceled by the field delete userid
        df_cancel_by_user = vy_sql.execute_query(config_file=CONFIG_FILE.get('etl').get('group_allotment'),
                                                 config_section='GET_SQL_CANCEL_FOR_USERS')

        logger.info(f'GET_SQL_CANCEL_FOR_USERS : {df_cancel_by_user.shape}')

        df_cancel_by_movement = get_sql_cancel_for_move_gral()
        logger.info(f'df_cancel_by_movement : {df_cancel_by_movement.shape}')

        df_not_exist = not_exist(df_cancel_by_movement, df_cancel_by_user)
        df_cancel = pd.concat([df_not_exist, df_cancel_by_user]).copy(deep=True)

        logger.info(f'END: {get_cancelled.__name__} : DONE')
        return df_cancel

    except Exception as ex:
        logger.error(f'ERROR: {get_cancelled.__name__} - {ex}')
        raise


def get_move_gral() -> pd.DataFrame:
    try:
        configs_tags = ['LOAD_SQL_STG_SALES_PAX', 'LOAD_SQL_STG_SALES_PAX_HI', 'LOAD_SQL_STG_SALES_ALL_PAX',
                        'LOAD_SQL_STG_MOV_GRAL']

        for conf in configs_tags:
            execute_sql_query(config_file=CONFIG_FILE.get('etl').get('group_allotment'),
                              config_section=conf)

        return vy_sql.execute_query(config_file=CONFIG_FILE.get('etl').get('group_allotment'),
                                    config_section='GET_SQL_MOVE_GRAL')

    except Exception as ex:
        logger.error(f'ERROR: {get_move_gral.__name__} - {ex}')
        raise


def swap_pax(row):
    """
      If the row is canceled with -2 and the number of pax is positive, we will change it to negative.
      @param row: movement row
      @return: pax number
      """
    try:
        return row[6] * -1 if row[9] == -2 and row[6] > 0 else row[6]
    except Exception as ex:
        logger.error(f'ERROR: {swap_pax.__name__} - {ex} ')
        raise


def change_version(row):
    """
       From the row the values are exchanged to generate a new movement.
       @param row: movement row
       @return: pax number
    """
    try:

        row[6] = abs(row[6])
        row[9] = 0
        return row
    except Exception as ex:
        logger.error(f'ERROR: {change_version.__name__} - {ex} ')
        raise


def get_cancel_hand(df_movements: pd.DataFrame, lt_fields_keys: list) -> pd.DataFrame:
    """
    We generate a new movement for those movements that have been manually canceled and do not have a version.
    @param df_movements: DataFrame with all movements
    @param lt_fields_keys: List of key fields
    @return: DataFramedata with all movements
    """

    try:

        logger.info(f'Start: {get_cancel_hand.__name__}')

        primary_keys = lt_fields_keys[0:2]
        pax = lt_fields_keys[3]
        status = lt_fields_keys[4]

        df_movements[pax] = df_movements.apply(swap_pax, axis=1)

        df_aux_cancel_hand = df_movements[df_movements[status] == -2]

        df_cancel_hand = df_aux_cancel_hand[primary_keys]
        df_canceled = df_movements.merge(df_cancel_hand.drop_duplicates(), how='inner',
                                         on=primary_keys,
                                         indicator=True,
                                         suffixes=('', '_DROP'))

        df_canceled.drop(columns=['_merge'], inplace=True)

        df_version = df_canceled.groupby(primary_keys).filter(lambda x: len(x) == 1)

        df_version = df_version.apply(change_version, axis=1)

        df_all_movements = pd.concat([df_movements, df_version]).copy()

        logger.info(f'END: {get_cancel_hand.__name__} : DONE')

        return df_all_movements

    except Exception as ex:
        logger.error(f'ERROR: {get_cancel_hand.__name__} - {ex} ')
        raise


def get_pending_flow(df_movements: pd.DataFrame, key_fields: list) -> pd.DataFrame:
    """
        Those movements that are in a pending state are canceled with -2 because their flight has already flown
        @param df_movements: DataFrame with all movements
        @param lt_fields_keys: List of key fields
        @return: DataFrame data with all movements
     """
    try:

        logger.info(f'Start: {get_pending_flow.__name__}')

        # Cast object to DT
        df_movements.AT_DT_FLIGHT = pd.to_datetime(df_movements.at_dt_flight)

        # We get the primmary fields Allotment_name, Inventorylegid
        primary_keys = key_fields[0:2]
        pax = key_fields[3]
        status = key_fields[4]
        dt_allotment_modified = key_fields[2]
        groupbyfields = key_fields[3:5]

        df_volados = df_movements[(df_movements.AT_DT_FLIGHT < pd.to_datetime('today').floor('D'))]

        df_volados[status] = df_volados[status].astype('int')
        df_pendientes_volados = df_volados.groupby(primary_keys)[groupbyfields].sum().reset_index()

        df_pendientes = df_pendientes_volados[
            (df_pendientes_volados[status] == 0) & (df_pendientes_volados[pax] > 0)]

        dflast_version = df_volados.groupby(primary_keys)[[dt_allotment_modified]].max().reset_index()

        # Primary Keys:Allotment_name, inventorylegid
        primary_keys = key_fields[0:2]
        df_canceled_version = dflast_version.merge(df_pendientes.drop_duplicates(), how='inner',
                                                   on=primary_keys,
                                                   indicator=True,
                                                   suffixes=('', '_DROP'))

        df_canceled_version.drop(columns=['_merge'], inplace=True)

        # Primary Keys:Allotment_name, inventorylegid, date Allotment Modified'
        primary_keys = key_fields[0:3]
        df_new_version = df_volados.merge(df_canceled_version.drop_duplicates(), how='inner',
                                          on=primary_keys,
                                          indicator=True,
                                          suffixes=('', '_DROP'))

        df_new_version[pax] = df_new_version[pax + '_DROP'] * -1
        df_new_version[status] = -2

        df_new_version.drop(columns=['_merge', f'{pax}_DROP', f'{status}_DROP'], inplace=True)

        df_all_movements = pd.concat([df_movements, df_new_version]).copy()

        logger.info(f'END: {get_pending_flow.__name__} : DONE')

        return df_all_movements

    except Exception as ex:
        logger.error(f'ERROR: {get_pending_flow.__name__} - {ex} ')
        raise


def get_movements(df_cancelled: pd.DataFrame) -> pd.DataFrame:
    """
        we obtain the movements generated by the allotments at flight level
        @param df_canceled: Dataframe with previously canceled movements
        @return: DataFramedata with all movements
     """
    try:

        logger.info(f'Start: {get_movements.__name__}')

        df_movements = get_move_gral()

        # movements are restored
        logger.info(f' df_movements : {df_movements.shape}')

        # we discard those movements that have already been determined as canceled
        df_not_exist = not_exist(df_cancelled, df_movements)

        df_all_movements = pd.concat([df_not_exist, df_movements]).copy()

        logger.info(f'END: {get_movements.__name__} : DONE')

        return df_all_movements

    except Exception as ex:
        logger.error(f'ERROR: {get_movements.__name__} - {ex} ')
        raise


def calc_sales(row):
    """
      calculate the sales price according to the number of people times the unit price.
      @param row: movement row
      @return: pax number
    """
    try:
        if abs(row['ca_pax']) >= row['quantity']:

            if row['productcode'] not in ('FLG', 'CON'):
                field = 'quantity'
            else:
                field = 'ca_pax'

            row["ca_sales"] = abs(row[field]) * row['unitprice']
        else:
            row["ca_sales"] = abs(row['ca_pax']) * row['unitprice']

        row["ca_sales"] = row["ca_sales"] * -1 if (row['ca_pax'] < 0) else row["ca_sales"]

        return row["ca_sales"]

    except Exception as ex:
        logger.error(f'ERROR: {calc_sales.__name__} - {ex} ')
        raise


def add_allotment_price(df_allotments: pd.DataFrame) -> pd.DataFrame:
    """
          retrieves the salesforce price and applies it to the allotment and flight level.
          @param df_allotments: allotment movements
          @return: returns the records with the prices applied
    """
    try:

        df_allotment_prices = vy_redshift.execute_query(config_file=CONFIG_FILE.get('etl').get('group_allotment'),
                                                        config_section='GET_ALLOTMENT_FLIGHT_PRICE')

        if not df_allotment_prices.empty:
            primary_keys = ["at_cd_allotment_name", "at_cd_flight_number", "at_dt_flight"]

            df_allotments_sales = df_allotments.merge(df_allotment_prices.drop_duplicates(), how='inner',
                                                      on=primary_keys,
                                                      indicator=True,
                                                      suffixes=('', '_DROP'))

            df_allotments_sales['ca_sales'] = df_allotments_sales.apply(calc_sales, axis=1)

            columns_drop = ['_merge', 'at_cd_airport_arr_DROP', 'at_cd_airport_dep_DROP', 'productcode', 'unitprice',
                            'quantity']

            df_allotments_sales.drop(columns=columns_drop, inplace=True)
            df_allotments_sales.fillna('', inplace=True)

            primary_groupby = ['at_cd_allotment_name', 'at_cd_flight_number', 'at_dt_flight', 'at_cd_airport_dep',
                               'at_cd_airport_arr', 'at_cd_organization', 'ca_pax', 'at_ts_allotment_created',
                               'at_ts_allotment_modifed', 'at_cd_status', 'at_dt_confirmed', 'at_cd_pnr_confirmed',
                               'id_inventory_leg', 'ts_creation', 'ts_modified']
            group_by_fields = ['ca_sales']

            df_allotments_sales_group = df_allotments_sales.groupby(primary_groupby, dropna=False
                                                                    )[group_by_fields].sum().reset_index()

            df_allotments_sales_group['ca_sales'] = df_allotments_sales_group['ca_sales'].astype('float64')

        else:
            df_allotments_sales_group = df_allotments

        return df_allotments_sales_group

    except Exception as ex:
        logger.error(f'ERROR: {add_allotment_price.__name__} - {ex} ')
        raise


def load_stg_allotments(start_date: str, end_date: str) -> None:
    """
              load the staging table of allotments to process.
              @param:  start date; allotment modification, end date;allotment modification end date
        """

    try:

        execute_sql_query(config_file=CONFIG_FILE.get('etl').get('group_allotment'),
                          config_section='LOAD_SQL_STG_GROUPS_ALLOTMENTS', params=[start_date, end_date])

        allotment_flown()

        logger.info(f'END: {load_stg_allotments.__name__} : DONE')

    except Exception as ex:
        logger.error(f'ERROR: {load_stg_allotments.__name__} - {ex} ')
        raise


def get_allotment_activity(start_date, end_date) -> pd.DataFrame:
    """
       Find and generate movements of allotments at flight level
       @return: pd.Dataframe: It returns a dataframe with all the group allotments cancelled.
    """
    try:
        logger.info(f'Start: {get_allotment_activity.__name__}')

        fields_keys = ['at_cd_allotment_name', 'id_inventory_leg', 'at_ts_allotment_modifed', 'ca_pax', 'at_cd_status']

        # Load stg_allotments_groups
        load_stg_allotments(start_date=start_date, end_date=end_date)

        # We look for those that have been canceled due to some anomaly
        df_cancelled = get_cancelled()

        # We obtain the movements of the allotments
        df_movements = get_movements(df_cancelled=df_cancelled)

        # We get those that we cancel because we have lost traceability
        if not df_movements.empty:
            df_movements = get_cancel_hand(df_movements=df_movements, lt_fields_keys=fields_keys)

        # we recover those that we have canceled because they have been
        # pending and have not flown

        if not df_movements.empty:
            df_movements = get_pending_flow(df_movements, fields_keys)

        logger.info(f'END: {get_allotment_activity.__name__} : DONE')

        return df_movements

    except Exception as ex:
        logger.error(f'ERROR: {get_allotment_activity.__name__} - {ex} ')
        raise


def save_to_s3(data: pd.DataFrame, filename: str) -> None:
    """
              upload allotments logs to S3
              @params: data; allotment records. filename; file name
           """
    try:

        create_folder(get_data_file_path(''))
        data.to_csv(get_data_file_path(filename), compression='gzip', sep='|', index=False)

        vy_s3.copy_from_local_to_s3(config_file=CONFIG_FILE.get('etl').get('group_allotment'),
                                    config_section='UPLOAD_TO_S3_GROUP_ALLOTMENT', data_files=filename)
    except Exception as ex:
        logger.error(f'ERROR: {save_to_s3.__name__} - {ex} ')
        raise


def copy_s3_to_stg(filename: str) -> None:
    try:

        logger.info(f'Start: {copy_s3_to_stg.__name__}')

        # {0}->TABLE_NAME, {1}->S3_PATH, {2}->AWS_ACCESS_KEY, {3}-> AWS_SECRET_ACCESS_KEY
        vy_redshift.copy_from_s3(config_file=CONFIG_FILE.get('etl').get('group_allotment'),
                                 config_section='COPY_FROM_S3_STG_CUST_GROUP_ALLOTMENT',
                                 params=[filename])
        logger.info(f'END: {copy_s3_to_stg.__name__} : DONE')
    except Exception as ex:
        logger.error(f'ERROR: {copy_s3_to_stg.__name__} - {ex} ')
        raise


def truncate_redshift_stg_table() -> None:
    """
      Truncate the records in the staging table
     """
    try:
        vy_redshift.execute_query(config_file=CONFIG_FILE.get('etl').get('group_allotment'),
                                  config_section='TRUNCATE_STG_CUST_GROUP_ALLOTMENT')
    except Exception as ex:
        logger.error(f'ERROR: {truncate_redshift_stg_table.__name__} - {ex} ')
        raise


def delete_existing_records() -> None:
    """
       we delete those records from the final table that exist in the staging table
    """
    try:
        vy_redshift.execute_query(config_file=CONFIG_FILE.get('etl').get('group_allotment'),
                                  config_section='DELETE_EXISTING_RECORDS_CUST_GROUP_ALLOTMENT')
    except Exception as ex:
        logger.error(f'ERROR: {delete_existing_records.__name__} - {ex} ')
        raise


def insert_data() -> None:
    """
        we insert the records from the staging table to the final table
    """
    try:
        vy_redshift.execute_query(config_file=CONFIG_FILE.get('etl').get('group_allotment'),
                                  config_section='INSERT_NEW_RECORDS')
    except Exception as ex:
        logger.error(f'ERROR: {insert_data.__name__} - {ex} ')
        raise


def allotment_flown() -> None:
    """
         It is checked if there is any allotment movement that is pending the flight already flown.
         Yes that's how it is. It is inserted into the staging to be reprocessed
    """
    try:
        df_allotment_flown = vy_redshift.execute_query(config_file=CONFIG_FILE.get('etl').get('group_allotment'),
                                                       config_section='GET_ALLOTMENT_FLOWN')
        for index, row in df_allotment_flown.iterrows():

            logger.info('allotment_flown: ' + str(index) + ' de ' + str(len(df_allotment_flown.index)))

            allotment_name = row['at_cd_allotment_name']
            id_inventory_leg = row['id_inventory_leg']
            ts_modified = '2023-10-01 00:00:00.000'

            df_flown = vy_sql.execute_query(config_file=CONFIG_FILE.get('etl').get('group_allotment'),
                                            config_section='FIND_STG_ALLOTMENT',
                                            params=[allotment_name, id_inventory_leg])

            if df_flown.empty:
                execute_sql_query(config_file=CONFIG_FILE.get('etl').get('group_allotment'),
                                  config_section='INSERT_STG_ALLOTMENT',
                                  params=[allotment_name, id_inventory_leg, ts_modified])

    except Exception as ex:
        logger.error(f'ERROR: {allotment_flown.__name__} - {ex} ')
        raise


def load_to_table(schema_name: str, table_name: str, df: pd.DataFrame):
    """
     load a dataframe to a sql table
     @params: schema_name; table_name; df
    """
    try:
        df['at_dt_flight'] = pd.to_datetime(df['at_dt_flight'])
        df['at_dt_confirmed'] = pd.to_datetime(df['at_dt_confirmed'])

        filename = "groups_allotments_price.gzip"
        save_to_s3(data=df, filename=filename)

        truncate_redshift_stg_table()

        copy_s3_to_stg(filename=filename)

    except Exception as ex:
        logger.error(f'ERROR: {load_to_table.__name__} - {ex} ')
        raise


def load_stg_cust_allotment(df: pd.DataFrame):
    """
     load a dataframe to a sql table passed through S3
     @params: schema_name; table_name; df
    """
    try:

        filename = "groups_allotments.gzip"
        save_to_s3(data=df, filename=filename)

        truncate_redshift_stg_table()
        copy_s3_to_stg(filename=filename)

    except Exception as ex:
        logger.error(f'ERROR: {load_stg_cust_allotment.__name__} - {ex} ')
        raise


def allotments_move(start_date, end_date):
    """
         generates allotment movements
         @params: star_date; end_date;
    """

    try:
        df_allotments_move = get_allotment_activity(start_date, end_date)

        if not df_allotments_move.empty:
            df_allotments_move["ca_sales"] = 0.00
            load_stg_cust_allotment(df_allotments_move)

            return df_allotments_move

    except Exception as ex:
        logger.error(f'ERROR: {allotments_move.__name__} - {ex} ')
        raise


def allotments_move_price(df: pd.DataFrame):
    """
        adds the price to the allotment movements
        @params: df; all allotments movements
    """

    try:
        df_allotments_price = add_allotment_price(df)

        if not df_allotments_price.empty:
            # we trick the staging to reload them with the price
            load_to_table(schema_name='salesb2b', table_name='stg_cust_group_allotment', df=df_allotments_price)

    except Exception as ex:
        logger.error(f'ERROR: {allotments_move.__name__} - {ex} ')
        raise


def main(start_date, end_date):
    # We obtain the movements of the Allotments
    df_allotments_move = allotments_move(start_date, end_date)

    if not df_allotments_move.empty:
        # We calculate and add the price to the allotment movements
        allotments_move_price(df_allotments_move)

        # we update the allotments table
        delete_existing_records()
        insert_data()
