WITH QUERY1 AS 
(
    SELECT
        DMV.dbo.TA_rec_loc_otros1.rec_loc,
        dbo.DimChannel.channel_lvl2,
        dbo.DIM_FARE.AT_FAMILY_FARE_LVL0 ,
        sum(fsd.v_AUX_FSD_ACTUAL_MARKUP.MT_MARKUP) AS mups
    FROM dbo.FactFlight 
        INNER JOIN dbo.factSegment  DimSegment 
            ON (DimSegment.flight_sk=dbo.FactFlight.flight_sk)
        INNER JOIN dbo.FactPNR 
            ON (dbo.FactPNR.rec_loc=DimSegment.rec_loc)
        INNER JOIN dbo.dimsalesstatus 
            ON (dbo.dimsalesstatus.sales_sk=dbo.FactPNR.sales_sk)
        INNER JOIN dbo.factSegment_VentasChannel 
            ON (dbo.factSegment_VentasChannel.rec_loc=dbo.FactPNR.rec_loc)
        INNER JOIN dbo.DimChannel 
            ON (dbo.factSegment_VentasChannel.id_channel=dbo.DimChannel.id_channel)
        INNER JOIN DMV.dbo.TA_rec_loc_otros1 
            ON (DMV.dbo.TA_rec_loc_otros1.rec_loc=dbo.FactPNR.rec_loc)
        INNER JOIN dbo.factSegment 
            ON (dbo.factSegment.coupon_sk=DimSegment.coupon_sk)
        INNER JOIN fsd.v_AUX_FSD_ACTUAL_MARKUP 
            ON (fsd.v_AUX_FSD_ACTUAL_MARKUP.AT_CD_PNR=dbo.factSegment.rec_loc and fsd.v_AUX_FSD_ACTUAL_MARKUP.AT_CD_SEG_SEQ_NBR=dbo.factSegment.seg_seq_nbr and fsd.v_AUX_FSD_ACTUAL_MARKUP.AT_CD_PAX_NBR=dbo.factSegment.pax_nbr)
        INNER JOIN dbo.DIM_FARE 
            ON (dbo.DIM_FARE.ID_FARE=DimSegment.ID_FARE)
    WHERE ( dbo.dimsalesstatus.sales_sk not in (3)  )
        AND dbo.FactFlight.airline_code  IN  ( 'VY'  )
        AND (dbo.FactFlight.idStatus=1)
    GROUP BY
        DMV.dbo.TA_rec_loc_otros1.rec_loc, 
        dbo.DimChannel.channel_lvl2, 
        dbo.DIM_FARE.AT_FAMILY_FARE_LVL0
), QUERY2 AS
(
    SELECT
        DMV.dbo.TA_rec_loc_otros1.rec_loc,
        dbo.DimChannel.channel_lvl2,
        dbo.DIM_FARE.AT_FAMILY_FARE_LVL0 ,
        sum(dbo.factSegment.cdiscount+dbo.factSegment.reparto_Fees) AS rev
    FROM dbo.FactFlight 
        INNER JOIN dbo.factSegment  DimSegment 
            ON (DimSegment.flight_sk=dbo.FactFlight.flight_sk)
        INNER JOIN dbo.FactPNR 
            ON (dbo.FactPNR.rec_loc=DimSegment.rec_loc)
        INNER JOIN dbo.dimsalesstatus 
            ON (dbo.dimsalesstatus.sales_sk=dbo.FactPNR.sales_sk)
        INNER JOIN dbo.factSegment_VentasChannel 
            ON (dbo.factSegment_VentasChannel.rec_loc=dbo.FactPNR.rec_loc)
        INNER JOIN dbo.DimChannel 
            ON (dbo.factSegment_VentasChannel.id_channel=dbo.DimChannel.id_channel)
        INNER JOIN DMV.dbo.TA_rec_loc_otros1 
            ON (DMV.dbo.TA_rec_loc_otros1.rec_loc=dbo.FactPNR.rec_loc)
        INNER JOIN dbo.factSegment 
            ON (dbo.factSegment.coupon_sk=DimSegment.coupon_sk)
        INNER JOIN dbo.DIM_FARE 
            ON (dbo.DIM_FARE.ID_FARE=DimSegment.ID_FARE)
    WHERE ( dbo.dimsalesstatus.sales_sk not in (3) and dbo.FactFlight.airline_code=dbo.FactFlight.mktCarrierCode  )
        AND dbo.FactFlight.airline_code  IN  ( 'VY'  )
        AND (dbo.FactFlight.idStatus=1)
    GROUP BY
        DMV.dbo.TA_rec_loc_otros1.rec_loc, 
        dbo.DimChannel.channel_lvl2, 
        dbo.DIM_FARE.AT_FAMILY_FARE_LVL0 
)
SELECT q1.rec_loc,
        q1.AT_FAMILY_FARE_LVL0 AS "Sales Family",
        q1.channel_lvl2,
        q2.rev AS "Actual Ticket revenues Vueling",
        q1.mups AS "ACTUAL MARKUPS (MDS)"
FROM QUERY1 q1
    INNER JOIN QUERY2 q2
        ON q1.rec_loc = q2.rec_loc
		AND q1.channel_lvl2 = q2.channel_lvl2
		AND q1.AT_FAMILY_FARE_LVL0 = q2.AT_FAMILY_FARE_LVL0
ORDER BY q1.rec_loc