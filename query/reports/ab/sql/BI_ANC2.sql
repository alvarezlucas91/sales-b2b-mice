WITH QUERY1 AS
(
    SELECT
    dbo.DIM_FEE_TYPE.AT_DS_REVENUE_CONCEPT_3_GROUPED,
    DMV.dbo.TA_rec_loc_otros1.rec_loc,
    DMV_Vueling_ventas.dbo.V_FACT_FEE_ACTIVE.AT_IS_POST_BOOKING,
    dbo.DIM_FEE_TYPE.AT_DS_REVENUE_CONCEPT_2,
    case dbo.DIM_FEE_TYPE.AT_DS_REVENUE_CONCEPT_3
        when 'MIDDLE SEAT' then 'SPACE ONE'
        when 'PRIORITY SEAT' then 'SPACE PLUS'
        when 'OPTIMUM SEAT' then 'FRONT ROWS'
        when 'Xl SEAT' then 'SPACE'
        else dbo.DIM_FEE_TYPE.AT_DS_REVENUE_CONCEPT_3
    end AS AT_DS_REVENUE_CONCEPT_3,
    SUM(DMV_Vueling_ventas.dbo.V_FACT_FEE_ACTIVE.MT_COMPANY_BASE_AMOUNT) AS ancRev
    FROM dbo.FactFlight 
        RIGHT OUTER JOIN DMV_Vueling_ventas.dbo.V_FACT_FEE_ACTIVE 
            ON (dbo.FactFlight.flight_sk=DMV_Vueling_ventas.dbo.V_FACT_FEE_ACTIVE.ID_FLIGHT)
        INNER JOIN dbo.FactPNR 
            ON (dbo.FactPNR.rec_loc=DMV_Vueling_ventas.dbo.V_FACT_FEE_ACTIVE.AT_CD_PNR)
        INNER JOIN DMV.dbo.TA_rec_loc_otros1 
            ON (DMV.dbo.TA_rec_loc_otros1.rec_loc=dbo.FactPNR.rec_loc)
        INNER JOIN dbo.DIM_FEE_TYPE 
            ON (DMV_Vueling_ventas.dbo.V_FACT_FEE_ACTIVE.ID_FEE_TYPE=dbo.DIM_FEE_TYPE.ID_FEE_TYPE)
    WHERE ( dbo.DIM_FEE_TYPE.AT_DS_REVENUE_CONCEPT_1  not in ('TICKETS','OTHER')  )
    AND  
        (
        dbo.FactFlight.airline_code  IN  ( 'VY'  )
        AND  (dbo.FactFlight.idStatus=1)
        AND
        dbo.DIM_FEE_TYPE.AT_DS_REVENUE_CONCEPT_1  IN  ( '3RD PARTY ANCILIARY','ANCILIARY'  )
        )
    GROUP BY
    dbo.DIM_FEE_TYPE.AT_DS_REVENUE_CONCEPT_3_GROUPED, 
    DMV.dbo.TA_rec_loc_otros1.rec_loc, 
    DMV_Vueling_ventas.dbo.V_FACT_FEE_ACTIVE.AT_IS_POST_BOOKING, 
    dbo.DIM_FEE_TYPE.AT_DS_REVENUE_CONCEPT_2, 
    case dbo.DIM_FEE_TYPE.AT_DS_REVENUE_CONCEPT_3
    when 'MIDDLE SEAT' then 'SPACE ONE'
    when 'PRIORITY SEAT' then 'SPACE PLUS'
    when 'OPTIMUM SEAT' then 'FRONT ROWS'
    when 'Xl SEAT' then 'SPACE'
    else dbo.DIM_FEE_TYPE.AT_DS_REVENUE_CONCEPT_3
    end
), QUERY2 AS
(
    SELECT
    dbo.DIM_FEE_TYPE.AT_DS_REVENUE_CONCEPT_3_GROUPED,
    DMV.dbo.TA_rec_loc_otros1.rec_loc,
    DMV_Vueling_ventas.dbo.V_FACT_FEE_ACTIVE.AT_IS_POST_BOOKING,
    dbo.DIM_FEE_TYPE.AT_DS_REVENUE_CONCEPT_2,
    case dbo.DIM_FEE_TYPE.AT_DS_REVENUE_CONCEPT_3
    when 'MIDDLE SEAT' then 'SPACE ONE'
    when 'PRIORITY SEAT' then 'SPACE PLUS'
    when 'OPTIMUM SEAT' then 'FRONT ROWS'
    when 'Xl SEAT' then 'SPACE'
    else dbo.DIM_FEE_TYPE.AT_DS_REVENUE_CONCEPT_3
    end AS AT_DS_REVENUE_CONCEPT_3,
    SUM(DMV_Vueling_ventas.dbo.V_FACT_FEE_ACTIVE.MT_NUMBER_OF_FEES) AS nbrAnc
    FROM
    dbo.FactFlight 
        RIGHT OUTER JOIN DMV_Vueling_ventas.dbo.V_FACT_FEE_ACTIVE 
            ON (dbo.FactFlight.flight_sk=DMV_Vueling_ventas.dbo.V_FACT_FEE_ACTIVE.ID_FLIGHT)
        INNER JOIN dbo.FactPNR 
            ON (dbo.FactPNR.rec_loc=DMV_Vueling_ventas.dbo.V_FACT_FEE_ACTIVE.AT_CD_PNR)
        INNER JOIN DMV.dbo.TA_rec_loc_otros1 
            ON (DMV.dbo.TA_rec_loc_otros1.rec_loc=dbo.FactPNR.rec_loc)
        INNER JOIN dbo.DIM_FEE_TYPE 
            ON (DMV_Vueling_ventas.dbo.V_FACT_FEE_ACTIVE.ID_FEE_TYPE=dbo.DIM_FEE_TYPE.ID_FEE_TYPE)
    WHERE
    (
    dbo.FactFlight.airline_code  IN  ( 'VY'  )
        AND  (dbo.FactFlight.idStatus=1)
        AND dbo.DIM_FEE_TYPE.AT_DS_REVENUE_CONCEPT_1  IN  ( '3RD PARTY ANCILIARY','ANCILIARY'  )
    )
    GROUP BY
    dbo.DIM_FEE_TYPE.AT_DS_REVENUE_CONCEPT_3_GROUPED, 
    DMV.dbo.TA_rec_loc_otros1.rec_loc, 
    DMV_Vueling_ventas.dbo.V_FACT_FEE_ACTIVE.AT_IS_POST_BOOKING, 
    dbo.DIM_FEE_TYPE.AT_DS_REVENUE_CONCEPT_2, 
    case dbo.DIM_FEE_TYPE.AT_DS_REVENUE_CONCEPT_3
    when 'MIDDLE SEAT' then 'SPACE ONE'
    when 'PRIORITY SEAT' then 'SPACE PLUS'
    when 'OPTIMUM SEAT' then 'FRONT ROWS'
    when 'Xl SEAT' then 'SPACE'
    else dbo.DIM_FEE_TYPE.AT_DS_REVENUE_CONCEPT_3
    end 
)
SELECT q1.AT_DS_REVENUE_CONCEPT_3_GROUPED AS "Ancillary Category",
        q1.rec_loc,
        q1.AT_IS_POST_BOOKING AS "Is Post Booking",
        q1.AT_DS_REVENUE_CONCEPT_2 AS "Revenue Concept 2",
        q1.AT_DS_REVENUE_CONCEPT_3 AS "Revenue Concept 3",
        q1.ancRev AS "Ancillary Revenue",
        q2.nbrAnc AS "Number of Ancillaries"
FROM  QUERY1 q1 
    INNER JOIN QUERY2 q2 
        ON q1.rec_loc = q2.rec_loc 
		AND q1.AT_DS_REVENUE_CONCEPT_3 = q2.AT_DS_REVENUE_CONCEPT_3 
		AND q1.AT_IS_POST_BOOKING = q2.AT_IS_POST_BOOKING 
		AND q1.AT_DS_REVENUE_CONCEPT_3_GROUPED = q2.AT_DS_REVENUE_CONCEPT_3_GROUPED
		AND q1.AT_DS_REVENUE_CONCEPT_2 = q2.AT_DS_REVENUE_CONCEPT_2
ORDER BY q1.AT_DS_REVENUE_CONCEPT_3_GROUPED