COPY
{0}
        (
         at_cd_allotment_name,
         at_cd_flight_number,
         at_dt_flight,
         at_cd_airport_dep,
         at_cd_airport_arr,
         at_cd_organization,
         ca_pax,
         at_ts_allotment_created,
         at_ts_allotment_modifed,
         at_cd_status,
         at_dt_confirmed,
         at_cd_pnr_confirmed,
         id_inventory_leg,
         ts_creation,
         ts_modified,
         ca_sales
            )
    FROM '{1}{4}'
    iam_role 'arn:aws:iam::123456789012:role/vueling-redshift-role'
    region 'eu-west-1'
    DELIMITER '|' GZIP
    DATEFORMAT 'auto'
    TIMEFORMAT 'auto'
    IGNOREHEADER 1
    REMOVEQUOTES
    NULL AS ''
;
