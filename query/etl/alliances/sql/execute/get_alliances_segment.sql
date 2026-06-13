WITH aux AS (SELECT DISTINCT factsegment.rec_loc                                       AS at_cd_rec_loc,
                             factsegment.seg_seq_nbr                                   AS at_seg_seq_nbr,
                             factsegment.pax_nbr                                       AS at_pax_nbr,
                             pnr.nbr_of_pax                                            AS at_pnr_nbr_of_pax,
                             factsegment.is_cx                                         AS at_is_cx,
                             factsegment.cxSegInfAirport                               AS at_cx_from,
                             CASE
                                 WHEN factsegment.is_cx = 1
                                     THEN next_segment.seg_seq_nbr
                                 END                                                   AS at_cx_seg_seq_nbr,
                             COALESCE(factsegment.cdiscount, 0) + COALESCE(factsegment.reparto_Fees, 0) +
                             COALESCE(fee.AnciRev, 0)                                  AS ca_total_revenue,
                             flight.airline_code                                       AS at_cd_airline,
                             flight.airport_orig                                       AS at_cd_airport_orig,
                             flight.airport_dest                                       AS at_cd_airport_dest,
                             factsegment.placa                                         AS at_placa,
                             CASE
                                 WHEN factsegment.AT_CD_MKT_CARRIER_CODE = 'IB' AND factsegment.placa = '075'
                                     THEN 'IB'
                                 WHEN factsegment.AT_CD_MKT_CARRIER_CODE = 'IB' AND
                                      (factsegment.placa = '030' OR factsegment.isLevel = 1)
                                     THEN 'LV'
                                 WHEN factsegment.AT_CD_MKT_CARRIER_CODE = 'BA' OR factsegment.placa = '125'
                                     THEN 'BA'
                                 WHEN factsegment.AT_CD_MKT_CARRIER_CODE = 'QR' OR factsegment.placa = '157'
                                     THEN 'QR'
                                 WHEN factsegment.AT_CD_MKT_CARRIER_CODE = 'LA' OR factsegment.placa IN ('045', '957')
                                     THEN 'LA'
                                 WHEN factsegment.AT_CD_MKT_CARRIER_CODE = 'AA' OR factsegment.placa = '001'
                                     THEN 'AA'
                                 WHEN factsegment.placa = '160'
                                     THEN 'CX'
                                 WHEN factsegment.placa = '512'
                                     THEN 'RJ'
                                 WHEN factsegment.placa = '923'
                                     THEN 'SS'
                                 WHEN factsegment.placa = '880'
                                     THEN 'HU'
                                 WHEN factsegment.placa = '618'
                                     THEN 'SQ'
                                 WHEN factsegment.placa = '988'
                                     THEN 'OZ'
                                 WHEN factsegment.placa = '176'
                                     THEN 'EK'
                                 WHEN factsegment.placa = '999'
                                     THEN 'CA'
                                 WHEN factsegment.placa = '131'
                                     THEN 'JL'
                                 WHEN factsegment.placa = '053'
                                     THEN 'EI'
                                 WHEN factsegment.placa = '235'
                                     THEN 'TK'
                                 WHEN factsegment.placa = '607'
                                     THEN 'EY'
                                 ELSE factsegment.AT_CD_MKT_CARRIER_CODE
                                 END
                                                                                       AS at_cd_carrier,
                             CASE
                                 WHEN next_segment.placa = '030' AND next_segment.isLevel IS NULL AND
                                      next_segment.is_cx = 1
                                     THEN 'VY'
                                 WHEN next_segment.AT_CD_MKT_CARRIER_CODE = 'IB' AND next_segment.placa = '075' AND
                                      next_segment.is_cx = 1
                                     THEN 'IB'
                                 WHEN next_segment.AT_CD_MKT_CARRIER_CODE = 'IB' AND
                                      (next_segment.placa = '030' OR next_segment.isLevel = 1) AND
                                      next_segment.is_cx = 1
                                     THEN 'LV'
                                 WHEN (next_segment.AT_CD_MKT_CARRIER_CODE = 'BA' OR next_segment.placa = '125') AND
                                      next_segment.is_cx = 1
                                     THEN 'BA'
                                 WHEN (next_segment.AT_CD_MKT_CARRIER_CODE = 'QR' OR next_segment.placa = '157') AND
                                      next_segment.is_cx = 1
                                     THEN 'QR'
                                 WHEN (next_segment.AT_CD_MKT_CARRIER_CODE = 'LA' OR
                                       next_segment.placa IN ('045', '957')) AND next_segment.is_cx = 1
                                     THEN 'LA'
                                 WHEN (next_segment.AT_CD_MKT_CARRIER_CODE = 'AA' OR next_segment.placa = '001') AND
                                      next_segment.is_cx = 1
                                     THEN 'AA'
                                 WHEN next_segment.placa = '160' AND next_segment.is_cx = 1
                                     THEN 'CX'
                                 WHEN next_segment.placa = '512' AND next_segment.is_cx = 1
                                     THEN 'RJ'
                                 WHEN next_segment.placa = '923' AND next_segment.is_cx = 1
                                     THEN 'SS'
                                 WHEN next_segment.placa = '880' AND next_segment.is_cx = 1
                                     THEN 'HU'
                                 WHEN next_segment.placa = '618' AND next_segment.is_cx = 1
                                     THEN 'SQ'
                                 WHEN next_segment.placa = '988' AND next_segment.is_cx = 1
                                     THEN 'OZ'
                                 WHEN next_segment.placa = '176' AND next_segment.is_cx = 1
                                     THEN 'EK'
                                 WHEN next_segment.placa = '999' AND next_segment.is_cx = 1
                                     THEN 'CA'
                                 WHEN next_segment.placa = '131' AND next_segment.is_cx = 1
                                     THEN 'JL'
                                 WHEN next_segment.placa = '053' AND next_segment.is_cx = 1
                                     THEN 'EI'
                                 WHEN next_segment.placa = '235' AND next_segment.is_cx = 1
                                     THEN 'TK'
                                 WHEN next_segment.placa = '607' AND next_segment.is_cx = 1
                                     THEN 'EY'
                                 WHEN next_segment.placa IS NULL AND (next_segment.AT_CD_MKT_CARRIER_CODE IS NULL OR next_segment.AT_CD_MKT_CARRIER_CODE = '') AND next_segment.is_cx = 1
                                    THEN next_flight.mktCarrierCode
                                WHEN next_segment.placa IS NULL AND (next_segment.AT_CD_MKT_CARRIER_CODE IS NOT NULL OR next_segment.AT_CD_MKT_CARRIER_CODE != '') AND next_segment.is_cx = 1
                                    THEN next_segment.AT_CD_MKT_CARRIER_CODE
                                 END                                                   AS at_cx_carrier,
                             flight.AT_CD_AIRLINE_CODE_OPER                            AS at_cd_airline_oper,
                             flight.route_m                                            AS CD_ROUTE,
                             r.AT_DS_MARKET_RANKING                                    AS at_market,
                             flight.flight_number                                      AS at_cd_flight_number,
                             --CAST(pnr.booking_date AS DATE)                          AS at_dt_booking,
                             CAST(flight.flight_date AS DATE)                          AS at_dt_flight,
                             CAST(factsegment.AT_DT_SALE AS DATE)                      AS at_dt_sale,
                             factsegment.family_fare                                   as at_family_fare,
                             DATEDIFF(day, factsegment.AT_DT_SALE, flight.flight_date) AS at_ca_ndo,
                             dc.channel_lvl1                                           AS at_sales_channel_1,
                             dc.channel_lvl2                                           AS at_sales_channel_2,
                             dc.channel_lvl4                                           AS at_sales_channel_4,
                             dc.channel_lvl9                                           AS at_sales_channel_9,
                             pdc.channel_lvl1                                          AS at_physical_channel_1,
                             pdc.channel_lvl2                                          AS at_physical_channel_2,
                             GETDATE()                                                 AS ts_creation,
                             GETDATE()                                                 AS ts_modification


             FROM VUELING_CALCODS.dbo.factpnr pnr
WITH (NOLOCK)
    JOIN VUELING_CALCODS.dbo.factsegment factsegment
WITH (NOLOCK)
ON pnr.rec_loc = factsegment.rec_loc
    JOIN VUELING_CALCODS.dbo.FactFlight flight
WITH (NOLOCK)
ON flight.flight_sk = factsegment.flight_sk
    JOIN Vueling_Ventas.dbo.factSegment_VentasChannel fv
WITH (NOLOCK)
ON fv.rec_loc = pnr.rec_loc
    JOIN Vueling_Ventas.dbo.dimchannel dc
WITH (NOLOCK)
ON fv.id_channel = dc.id_channel
    JOIN VUELING_CALCODS.dbo.DimChannelPhysical pdc
WITH (NOLOCK)
ON pdc.id_channel_physical = pnr.id_PhysicalChannel
    JOIN Vueling_data_master.dbo.DIM_ROUTE r
WITH (NOLOCK)
ON flight.airport_orig = r.AT_CD_ORIG and flight.airport_dest = r.AT_CD_DEST
    LEFT JOIN (SELECT fee.AT_CD_PNR,
    fee.AT_CD_PAX_NBR,
    fee.AT_CD_SEG_SEQ_NBR,
    SUM (fee.MT_COMPANY_BASE_AMOUNT) AS AnciRev
    FROM VUELING_CALCODS.fees.FACT_FEE fee WITH (NOLOCK)
    JOIN Vueling_data_master.dbo.DIM_FEE_TYPE dft WITH (NOLOCK)
    ON dft.ID_FEE_TYPE = fee.ID_FEE_TYPE
    WHERE dft.AT_DS_REVENUE_CONCEPT_1 IN ('ANCILLARY', 'ANCILIARY')
    AND fee.AT_IS_AUTOGENERATED_FEE = 0
    AND fee.OT_DT_END_DATE = '29991231'
    GROUP BY fee.AT_CD_PNR, fee.AT_CD_PAX_NBR, fee.AT_CD_SEG_SEQ_NBR) fee
    ON fee.AT_CD_PNR = factsegment.rec_loc AND fee.AT_CD_PAX_NBR = factsegment.pax_nbr AND
    fee.AT_CD_SEG_SEQ_NBR = factsegment.seg_seq_nbr
    LEFT JOIN VUELING_CALCODS..factsegment next_segment
WITH (NOLOCK)
ON factsegment.rec_loc = next_segment.rec_loc
    AND factsegment.JourneyNumberCalc = next_segment.JourneyNumberCalc
    AND factsegment.seg_seq_nbr != next_segment.seg_seq_nbr
    JOIN VUELING_CALCODS.dbo.FactFlight next_flight
WITH (NOLOCK)
ON next_flight.flight_sk = next_segment.flight_sk
WHERE 1 = 1
  AND ((flight.flight_date BETWEEN '{0}'
  AND '{1}')
   OR (flight.flight_date <= '{1}'
  AND pnr.modified_date BETWEEN '{0}'
  AND '{1}'))
  AND pnr.sales_sk
    < 3
  AND factsegment.AT_CD_MKT_CARRIER_CODE != ''
  AND factsegment.AT_CD_MKT_CARRIER_CODE IS NOT NULL
    )
SELECT *,
       CASE
           WHEN aux.at_cd_carrier = aux.at_cd_airline_oper
               THEN 0
           ELSE 1
           END AS at_is_alliance
FROM aux;