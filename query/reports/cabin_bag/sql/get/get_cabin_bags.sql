SELECT *, (POR.TOTAL_BAGS_ONBOARD * 100 / COALESCE(POR.CAPACITYBAGS, 1)) AS PORCENTAJE
FROM (SELECT RESULTADO.FLIGHT_DATE,
             RESULTADO.FLIGHT_NUMBER,
             RESULTADO.AIRPORT_ORIG,
             RESULTADO.AIRPORT_DEST,
             RESULTADO.FLIGHT_DATE_D,
             RESULTADO.FLIGHT_DATE_A,
             RESULTADO.LID,
             RESULTADO.SEATS,
             RESULTADO.EQUIPMENTTYPE,
             RESULTADO.TOTAL_PAX,
             RESULTADO.PRBZ,
             RESULTADO.SPACE1_PLUS,
             RESULTADO.TIMEFLEX,
             RESULTADO.OPTIMA_FAMILY,
             RESULTADO.GCBG,
             RESULTADO.OTHER_PRIORITY,
             RESULTADO.SHMD_CONNECTIONS,
             RESULTADO.FLY_WITH_CABIN,
             RESULTADO.TOTAL_BAGS_ONBOARD,
             RESULTADO.CAPACITYBAGS
      FROM (SELECT CAST(F.FLIGHT_DATE AS DATE)      AS FLIGHT_DATE,
                   F.FLIGHT_NUMBER                  AS FLIGHT_NUMBER,
                   F.AIRPORT_ORIG                   AS AIRPORT_ORIG,
                   F.AIRPORT_DEST                   AS AIRPORT_DEST,
                   CONVERT(CHAR (5), F.STDUTC, 108) AS FLIGHT_DATE_D,
                   CONVERT(CHAR (5), F.STAUTC, 108) AS FLIGHT_DATE_A,
                   F.LID                            AS LID,
                   F.SEATS                          AS SEATS,
                   F.EQUIPMENTTYPE                  AS EQUIPMENTTYPE,
                   COUNT(*)                         AS TOTAL_PAX,
                   COUNT(CASE
                             WHEN X.ATR = 1
                                 THEN 1
                       END)                         AS PRBZ,
                   COUNT(CASE
                             WHEN X.ATR = 2
                                 THEN 1
                       END)                         AS SPACE1_PLUS,
                   COUNT(CASE
                             WHEN X.ATR = 3
                                 THEN 1
                       END)                         AS TIMEFLEX,
                   COUNT(CASE
                             WHEN X.ATR = 4
                                 THEN 1
                       END)                         AS OPTIMA_FAMILY,
                   COUNT(CASE
                             WHEN X.ATR = 5
                                 THEN 1
                       END)                         AS GCBG,
                   COUNT(CASE
                             WHEN X.ATR = 6
                                 THEN 1
                       END)                         AS OTHER_PRIORITY,
                   COUNT(CASE
                             WHEN X.ATR = 7
                                 THEN 1
                       END)                         AS SHMD_CONNECTIONS,
                COUNT(CASE
                             WHEN X.ATR = 8
                                 THEN 1
                       END)                         AS FLY_WITH_CABIN,
                   --COUNT(CASE WHEN ATR = 10 THEN 1 END) RESTO,
                   COUNT(CASE
                             WHEN X.ATR >= 1
                                 AND X.ATR <= 8
                                 THEN 1
                       END)                         AS TOTAL_BAGS_ONBOARD,
                   --321 = C220, 110 MALETAS
                   --320 = C180, 80 MALETAS
                   --32A = C186, 80 MALETAS
                   --319 = C144, 60 MALETAS
                   --EIB = C180, 80 MALETAS
                   --32V = C180, 80 MALETAS
                   --32Q = C236, 110 MALETAS
                   --SUB = C186, 80 MALETAS
                   --CH2 = C
                   (CASE
                        WHEN F.EQUIPMENTTYPE = '321'
                            THEN 110
                        WHEN F.EQUIPMENTTYPE = '320'
                            THEN 80
                        WHEN F.EQUIPMENTTYPE = '32A'
                            THEN 80
                        WHEN F.EQUIPMENTTYPE = '319 '
                            THEN 60
                        WHEN F.EQUIPMENTTYPE = 'EIB'
                            THEN 80
                        WHEN F.EQUIPMENTTYPE = '32V'
                            THEN 80
                        WHEN F.EQUIPMENTTYPE = '32Q'
                            THEN 110
                        WHEN F.EQUIPMENTTYPE = 'SUB'
                            THEN 80
                        ELSE 1
                       END)                         AS CAPACITYBAGS
            FROM (SELECT AUX.CD_REC_LOC     AS CD_REC_LOC,
                         AUX.CD_SEG_SEQ_NBR AS CD_SEG_SEQ_NBR,
                         AUX.CD_PAX_NBR     AS CD_PAX_NBR,
                         AUX.ID_FLIGHT      AS ID_FLIGHT,
                         MIN(ATR)           AS ATR
                  FROM Vueling_CALCODS.DBO.AUX_GUARANTEED_CABIN_BAG AUX
                  GROUP BY AUX.CD_REC_LOC,
                           AUX.CD_SEG_SEQ_NBR,
                           AUX.ID_FLIGHT,
                           AUX.CD_PAX_NBR) X
                     INNER JOIN Vueling_CALCODS.DBO.FACTFLIGHT F WITH(NOLOCK)
            ON X.ID_FLIGHT = F.FLIGHT_SK AND F.equipmenttype != 'LV0'
            GROUP BY F.FLIGHT_DATE,
                F.FLIGHT_NUMBER,
                F.AIRPORT_ORIG,
                F.AIRPORT_DEST,
                F.STDUTC,
                F.STAUTC,
                F.LID,
                F.SEATS,
                F.EQUIPMENTTYPE) RESULTADO) POR