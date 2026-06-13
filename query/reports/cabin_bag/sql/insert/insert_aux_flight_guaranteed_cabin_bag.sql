INSERT INTO Vueling_CALCODS.dbo.AUX_FLIGHTS_GUARANTEED_CABIN_BAG
SELECT
	p.rec_loc CD_REC_LOC, s.seg_seq_nbr CD_SEG_SEQ_NBR, s.pax_nbr CD_PAX_NBR, S.flight_sk ID_FLIGHT
	FROM  Vueling_CALCODS.dbo.factPnr p WITH (NOLOCK)
		JOIN Vueling_CALCODS.dbo.factSegment s WITH (NOLOCK)  ON p.rec_loc=s.rec_loc
		JOIN Vueling_CALCODS.dbo.FactFlight f  WITH (NOLOCK) ON s.flight_sk=f.flight_sk
	WHERE f.flight_date between 
	    DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()) - 1, 0) --Primer dia mes anterior
	    AND DATEADD(DAY, - DAY(GETDATE()), GETDATE()) --Último día del mes anterior
	and f.mktCarrierCode = 'VY';

