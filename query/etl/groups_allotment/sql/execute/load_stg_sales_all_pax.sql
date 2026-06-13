TRUNCATE TABLE vueling_calcods.dbo.stg_AllPax_gral;
INSERT INTO  vueling_calcods.dbo.stg_AllPax_gral (
                                                inventorylegid
                                                ,AT_ALLOTMENT_NAME
                                                ,CA_PAX
                                                ,AT_FLIGHT_NUMBER
                                                ,AT_DT_FLIGHT
                                                ,AT_AIRPORT_DEP
                                                ,AT_AIRPORT_ARR
                                                ,AT_AGENT_NAME
                                                ,TS_ALLORMENT_CREATEDUTC
                                                ,TS_ALLOTMENT_MODIFEDUTC
                                                ,AT_MOVE_SALES
                                                ,AT_DT_CONFUTC
                                                ,PnrConf
                                                ,ClassNest
                                                )
SELECT
	il.inventorylegid,
	ilc.ClassOfService AS AT_ALLOTMENT_NAME,
	-ilc.ClassAllotted AS CA_PAX,
 	il.FlightNumber AS AT_FLIGHT_NUMBER,
	il.DepartureDate AS AT_DT_FLIGHT,
	il.DepartureStation AS AT_AIRPORT_DEP,
	il.ArrivalStation AS AT_AIRPORT_ARR,
	 AG.AGENTNAME AS AT_AGENT_NAME,
	ilc.CreatedUTC AS TS_ALLORMENT_CREATEDUTC,
	ilc.ModifiedUTC AS TS_ALLOTMENT_MODIFEDUTC,
	(CASE WHEN  ilc.ClassAllotted = 0 THEN -1
	      WHEN ilc.ClassAllotted > 0 AND PnrConf IS NOT NULL THEN 1
	      WHEN ilc.ClassAllotted > 0 AND PnrConf IS NULL  AND il.DepartureDate <CAST(GETDATE()AS DATE) THEN -2
	ELSE 0 END )AT_MOVE_SALES,
	AT_DT_CONFUTC,
	PnrConf,
	ilc.ClassNest
 FROM
	dbo.InventoryLeg il with(nolock)
	INNER JOIN Rez.InventoryLegNest iln with(nolock) ON il.inventorylegid = iln.inventorylegid
	INNER JOIN Rez.InventoryLegClass ilc with(nolock) ON iln.inventorylegid = ilc.inventorylegid AND iln.ClassNest = ilc.ClassNest
    INNER JOIN REZ.AGENT AG with(nolock)
	       ON il.ModifiedAgentID = AG.AGENTID
    INNER JOIN  vueling_calcods.dbo.stg_Allotment_gral al  ON al.ClassOfService = ilc.ClassOfService and    al.InventoryLegID = ilc.inventorylegid
	LEFT JOIN ( SELECT  paxHi.inventoryLegID,paxHi.at_Allotment, paxHi.DateAllotmentModifiedUTC,
							AT_DT_CONFUTC, PnrConf,NumPaxVendidos
				FROM vueling_calcods.dbo.stg_SalesPax_Hi_gral paxHi
				UNION
				SELECT  inventoryLegID,at_Allotment, DateAllotmentModifiedUTC,
						AT_DT_CONFUTC, PnrConf,NumPaxVendidos
				from vueling_calcods.dbo.stg_SalesPax_gral
				) CF
				ON IL.INVENTORYLEGID = CF.INVENTORYLEGID AND ILC.ClassOfService  = CF.AT_ALLOTMENT
		 WHERE il.CarrierCode = 'VY' and ilc.CreatedUTC>='2022-10-04 00:00:00.000' and
		  ilc.ClassType = 'N'
		   and   (ilc.ClassAllotted>0 )and isnull(NumPaxVendidos,0) >0;  -- Vendidos

