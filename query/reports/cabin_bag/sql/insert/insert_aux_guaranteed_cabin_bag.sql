
-- ALL
INSERT INTO Vueling_CALCODS.dbo.AUX_GUARANTEED_CABIN_BAG
       SELECT CD_REC_LOC,
              CD_SEG_SEQ_NBR,
              CD_PAX_NBR,
              ID_FLIGHT,
              10 atr
       FROM Vueling_CALCODS.dbo.AUX_FLIGHTS_GUARANTEED_CABIN_BAG;

--1. Pax with Priority Boarding (SSR PRBZ).
INSERT INTO Vueling_CALCODS.dbo.AUX_GUARANTEED_CABIN_BAG
       SELECT ssr.rec_loc,
              ssr.seg_seq_nbr,
              ssr.pax_nbr,
              af.ID_FLIGHT,
              1 AS atr
       FROM Vueling_ODS.dbo.segment_ssr ssr WITH(NOLOCK)
            INNER JOIN Vueling_CALCODS.dbo.AUX_FLIGHTS_GUARANTEED_CABIN_BAG af ON ssr.rec_loc = af.CD_REC_LOC
                                                                  AND ssr.seg_seq_nbr = af.CD_SEG_SEQ_NBR
                                                                  AND ssr.PAX_NBR = af.CD_PAX_NBR
       WHERE ssr_code = 'PRBZ';

--2. Pax with a Space One/Space Plus seat (seats that include Priority Boarding).
INSERT INTO Vueling_CALCODS.dbo.AUX_GUARANTEED_CABIN_BAG
       SELECT DISTINCT
              ff.AT_CD_PNR,
              ff.AT_CD_SEG_SEQ_NBR,
              ff.AT_CD_PAX_NBR,
              af.ID_FLIGHT,
              2 AS atr
       FROM Vueling_CALCODS.[fees].[FACT_FEE] ff WITH(NOLOCK)
            INNER JOIN Vueling_data_master.dbo.DIM_FEE_TYPE df WITH(NOLOCK) ON ff.id_fee_type = df.ID_FEE_TYPE
            JOIN Vueling_CALCODS.dbo.AUX_FLIGHTS_GUARANTEED_CABIN_BAG af ON ff.id_flight = af.ID_FLIGHT
       WHERE ff.OT_DT_END_DATE = '29991231'
             AND df.AT_DS_REVENUE_CONCEPT_3 IN('MIDDLE SEAT', 'PRIORITY SEAT');

--3. Pax flying with Time&Flex fare and VCB3 bundle
INSERT INTO Vueling_CALCODS.dbo.AUX_GUARANTEED_CABIN_BAG
       SELECT s.rec_loc,
              s.seg_seq_nbr,
              s.pax_nbr,
              s.flight_sk,
              3 AS atr
       FROM Vueling_CALCODS.dbo.factSegment s WITH(NOLOCK)
            INNER JOIN Vueling_CALCODS.dbo.AUX_FLIGHTS_GUARANTEED_CABIN_BAG af ON S.rec_loc = af.CD_REC_LOC
                                                                  AND S.seg_seq_nbr = af.CD_SEG_SEQ_NBR
                                                                  AND S.PAX_NBR = af.CD_PAX_NBR
            JOIN Vueling_CALCODS.dbo.DIM_FARE df WITH(NOLOCK) ON df.ID_FARE = S.ID_FARE
       WHERE AT_FAMILY_FARE_lvl0 = 'TIME FLEX'
             AND OT_DT_END_DATE = '9999-12-31';

INSERT INTO Vueling_CALCODS.dbo.AUX_GUARANTEED_CABIN_BAG
SELECT fs.rec_loc,
       fs.seg_seq_nbr,
       fs.pax_nbr,
       fs.flight_sk,
       3 AS atr
FROM Vueling_CALCODS.dbo.factSegment fs WITH (NOLOCK)
         JOIN Vueling_CALCODS.dbo.AUX_FLIGHTS_GUARANTEED_CABIN_BAG af
              ON fs.rec_loc = af.CD_REC_LOC AND fs.seg_seq_nbr = af.CD_SEG_SEQ_NBR
                  AND fs.seg_seq_nbr = af.CD_SEG_SEQ_NBR
         JOIN VUELING_CALCODS.fees.FACT_FEE fee
              ON fee.AT_CD_PNR = fs.rec_loc AND fee.AT_CD_SEG_SEQ_NBR = fs.seg_seq_nbr AND
                 fee.AT_CD_PAX_NBR = fs.pax_nbr
         JOIN vueling_data_master.dbo.dim_fee_type dft ON dft.id_fee_type = fee.id_fee_type
WHERE dft.AT_CD_SERVICE_TYPE = 'VCB3';


--4. Pax flying with Optima/Family family fares.
INSERT INTO Vueling_CALCODS.dbo.AUX_GUARANTEED_CABIN_BAG
       SELECT s.rec_loc,
              s.seg_seq_nbr,
              s.pax_nbr,
              s.flight_sk,
              4 AS atr
       FROM Vueling_CALCODS.dbo.factSegment s WITH(NOLOCK)
            INNER JOIN Vueling_CALCODS.dbo.AUX_FLIGHTS_GUARANTEED_CABIN_BAG af ON S.rec_loc = af.CD_REC_LOC
                                                                  AND S.seg_seq_nbr = af.CD_SEG_SEQ_NBR
                                                                  AND S.PAX_NBR = af.CD_PAX_NBR
            INNER JOIN Vueling_CALCODS.dbo.DIM_FARE df WITH(NOLOCK) ON df.ID_FARE = S.ID_FARE
       WHERE AT_FAMILY_FARE_lvl0 IN('OPTIMA', 'FAMILY FIRST')
            AND OT_DT_END_DATE = '9999-12-31';




--5. Pax with buying the new product.

INSERT INTO Vueling_CALCODS.dbo.AUX_GUARANTEED_CABIN_BAG
       SELECT DISTINCT
              s.rec_loc,
              s.seg_seq_nbr,
              s.pax_nbr,
              s.flight_sk,
              5 AS atr
        --,AT_FAMILY_FARE,ssr_code

       FROM Vueling_CALCODS.dbo.factSegment s WITH(NOLOCK)
            INNER JOIN Vueling_CALCODS.dbo.AUX_FLIGHTS_GUARANTEED_CABIN_BAG af ON S.rec_loc = af.CD_REC_LOC
                                                                  AND S.seg_seq_nbr = af.CD_SEG_SEQ_NBR
                                                                  AND S.PAX_NBR = af.CD_PAX_NBR
            LEFT JOIN Vueling_ODS.dbo.segment_ssr ssr WITH(NOLOCK) ON ssr.rec_loc = af.CD_REC_LOC
                                                                      AND ssr.seg_seq_nbr = af.CD_SEG_SEQ_NBR
                                                                      AND ssr.PAX_NBR = af.CD_PAX_NBR
            LEFT JOIN Vueling_CALCODS.dbo.DIM_FARE df WITH(NOLOCK) ON df.ID_FARE = S.ID_FARE
       WHERE(AT_FAMILY_FARE = 'Basic'
             AND OT_DT_END_DATE = '9999-12-31'
            AND ssr_code = 'GCBG')

			--or (AT_FAMILY_FARE = 'GDS Optima'
   --          AND OT_DT_END_DATE = '9999-12-31')
			 ;




--6. Premium Pax.
--ssr_code IN('INFT','BLND','DEAF','DPNA','WCHS','WCHC','WCHR','PRVG')

INSERT INTO Vueling_CALCODS.dbo.AUX_GUARANTEED_CABIN_BAG
       SELECT DISTINCT
              s.rec_loc,
              s.seg_seq_nbr,
              s.pax_nbr,
              s.flight_sk,
              6 AS atr
       -- ,AT_FAMILY_FARE,ssr_code

       FROM Vueling_CALCODS.dbo.factSegment s WITH(NOLOCK)
            INNER JOIN Vueling_CALCODS.dbo.AUX_FLIGHTS_GUARANTEED_CABIN_BAG af ON S.rec_loc = af.CD_REC_LOC
                                                                  AND S.seg_seq_nbr = af.CD_SEG_SEQ_NBR
                                                                  AND S.PAX_NBR = af.CD_PAX_NBR
            inner JOIN Vueling_ODS.dbo.segment_ssr ssr WITH(NOLOCK) ON ssr.rec_loc = af.CD_REC_LOC
                                                                      AND ssr.seg_seq_nbr = af.CD_SEG_SEQ_NBR
                                                                      AND ssr.PAX_NBR = af.CD_PAX_NBR
            LEFT JOIN Vueling_CALCODS.dbo.DIM_FARE df WITH(NOLOCK) ON df.ID_FARE = S.ID_FARE
       WHERE(AT_FAMILY_FARE = 'Basic'
             AND OT_DT_END_DATE = '9999-12-31')
            AND ssr_code = 'PRVG';

--6. PMR.
INSERT INTO Vueling_CALCODS.dbo.AUX_GUARANTEED_CABIN_BAG
       SELECT ssr.rec_loc,
              ssr.seg_seq_nbr,
              ssr.pax_nbr,
              af.ID_FLIGHT,
              6 AS atr
			 --   ,AT_FAMILY_FARE,ssr_code,ssr_enc.CD_SSR_CODE
       FROM Vueling_CALCODS.dbo.factSegment s WITH(NOLOCK)
            INNER JOIN Vueling_CALCODS.dbo.AUX_FLIGHTS_GUARANTEED_CABIN_BAG af ON S.rec_loc = af.CD_REC_LOC
                                                                  AND S.seg_seq_nbr = af.CD_SEG_SEQ_NBR
                                                                  AND S.PAX_NBR = af.CD_PAX_NBR
            inner JOIN vueling_navitaire.dbo.v_segment_ssr_pmr ssr WITH(NOLOCK) ON ssr.rec_loc = af.CD_REC_LOC
                                                                      AND ssr.seg_seq_nbr = af.CD_SEG_SEQ_NBR
                                                                      AND ssr.PAX_NBR = af.CD_PAX_NBR
			inner JOIN Vueling_data_master.dbo.LKP_SSR_ENCRYPTED ssr_enc WITH(NOLOCK) ON ssr_enc.CD_SSR_CODE = ssr.ssr_code
            LEFT JOIN Vueling_CALCODS.dbo.DIM_FARE df WITH(NOLOCK) ON df.ID_FARE = S.ID_FARE
       WHERE(AT_FAMILY_FARE = 'Basic'
             AND OT_DT_END_DATE = '9999-12-31');





--6. INFANTS.
INSERT INTO Vueling_CALCODS.dbo.AUX_GUARANTEED_CABIN_BAG
       SELECT DISTINCT
              s.rec_loc,
              s.seg_seq_nbr,
              s.pax_nbr,
              s.flight_sk,
              6 AS atr
       -- ,AT_FAMILY_FARE,ssr_code

       FROM Vueling_CALCODS.dbo.factSegment s WITH(NOLOCK)
            INNER JOIN Vueling_CALCODS.dbo.AUX_FLIGHTS_GUARANTEED_CABIN_BAG af ON S.rec_loc = af.CD_REC_LOC
                                                                  AND S.seg_seq_nbr = af.CD_SEG_SEQ_NBR
                                                                  AND S.PAX_NBR = af.CD_PAX_NBR
            inner JOIN Vueling_ODS.dbo.segment_ssr ssr WITH(NOLOCK) ON ssr.rec_loc = af.CD_REC_LOC
                                                                      AND ssr.seg_seq_nbr = af.CD_SEG_SEQ_NBR
                                                                      AND ssr.PAX_NBR = af.CD_PAX_NBR
            LEFT JOIN Vueling_CALCODS.dbo.DIM_FARE df WITH(NOLOCK) ON df.ID_FARE = S.ID_FARE
       WHERE(AT_FAMILY_FARE = 'Basic'
             AND OT_DT_END_DATE = '9999-12-31')
            AND ssr_code = 'INFT';


--7. Pax with Short-Medium Connections (under 90 minutes)
INSERT INTO Vueling_CALCODS.dbo.AUX_GUARANTEED_CABIN_BAG
       SELECT p.rec_loc,
              s.seg_seq_nbr,
              s.pax_nbr,
              s.flight_sk,
              7 AS atr
       FROM Vueling_CALCODS.dbo.factPnr p WITH(NOLOCK)
            INNER JOIN Vueling_CALCODS.dbo.factSegment s WITH(NOLOCK) ON p.rec_loc = s.rec_loc
            INNER JOIN Vueling_CALCODS.dbo.FactFlight f WITH(NOLOCK) ON s.flight_sk = f.flight_sk
            INNER JOIN Vueling_CALCODS.dbo.factSegment s1 WITH(NOLOCK) ON s1.rec_loc = s.rec_loc
                                                                          AND s1.pax_nbr = s.pax_nbr
                                                                          AND s1.JourneyNumber = s.JourneyNumber
                                                                          AND s1.SegmentNumber - 1 = s.SegmentNumber
            INNER JOIN Vueling_CALCODS.dbo.FactFlight f1 WITH(NOLOCK) ON s1.flight_sk = f1.flight_sk
			  LEFT JOIN Vueling_CALCODS.dbo.DIM_FARE df WITH(NOLOCK) ON df.ID_FARE = S.ID_FARE
       WHERE
             f.flight_date between
                DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 1, 0)
                AND DATEADD(DAY, - DAY(GETDATE()), GETDATE())
             AND f.mktCarrierCode = 'VY'
             AND s.is_cxIB = 1
             AND DATEDIFF(MINUTE, f.STAUTC, f1.STDUTC) BETWEEN 0 AND 90
			 and (AT_FAMILY_FARE = 'Basic'
             AND OT_DT_END_DATE = '9999-12-31') ;


-- Bundles VCB2 - Fly with Cabin
INSERT INTO Vueling_CALCODS.dbo.AUX_GUARANTEED_CABIN_BAG
SELECT fs.rec_loc,
       fs.seg_seq_nbr,
       fs.pax_nbr,
       fs.flight_sk,
       8 AS atr
FROM Vueling_CALCODS.dbo.factSegment fs WITH (NOLOCK)
         JOIN Vueling_CALCODS.dbo.AUX_FLIGHTS_GUARANTEED_CABIN_BAG af
              ON fs.rec_loc = af.CD_REC_LOC AND fs.seg_seq_nbr = af.CD_SEG_SEQ_NBR
                  AND fs.seg_seq_nbr = af.CD_SEG_SEQ_NBR
         JOIN VUELING_CALCODS.fees.FACT_FEE fee
              ON fee.AT_CD_PNR = fs.rec_loc AND fee.AT_CD_SEG_SEQ_NBR = fs.seg_seq_nbr AND
                 fee.AT_CD_PAX_NBR = fs.pax_nbr
         JOIN vueling_data_master.dbo.dim_fee_type dft ON dft.id_fee_type = fee.id_fee_type
WHERE dft.AT_CD_SERVICE_TYPE = 'VCB2';