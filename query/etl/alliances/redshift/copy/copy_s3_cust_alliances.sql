COPY
{0}
        (
       at_cd_rec_loc,
       at_seg_seq_nbr,
       at_pax_nbr,
       at_pnr_nbr_of_pax,
       at_is_cx,
       at_cx_from,
       at_cx_seg_seq_nbr,
       ca_total_revenue,
       at_cd_airline,
       at_cd_airport_orig,
       at_cd_airport_dest,
       at_placa,
       at_cd_carrier,
       at_cx_carrier,
       at_cd_airline_oper,
       at_route,
       at_market,
       at_cd_flight_number,
       --at_dt_booking,
       at_dt_flight,
       at_dt_sale,
       at_family_fare,
       at_ca_ndo,
       at_sales_channel_1,
       at_sales_channel_2,
       at_sales_channel_4,
       at_sales_channel_9,
       at_physical_channel_1,
       at_physical_channel_2,
       ts_creation,
       ts_modification,
       at_is_alliance)
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
