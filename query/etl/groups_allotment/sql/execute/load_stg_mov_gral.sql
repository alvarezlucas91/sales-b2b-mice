TRUNCATE TABLE  vueling_calcods.dbo.stg_mov_gral;
INSERT INTO vueling_calcods.dbo.stg_mov_gral (
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
	                                        ts_modified
                                           )
    SELECT
            ClassOfService as AT_CD_ALLOTMENT_NAME,
            FlightNumber as AT_CD_FLIGHT_NUMBER,
            DepartureDate as AT_DT_FLIGHT,
            DepartureStation as AT_CD_AIRPORT_DEP,
	        ArrivalStation as  AT_CD_AIRPORT_ARR,
	        agentname as  AT_CD_ORGANIZATION,
            PAX as CA_PAX,
            CONVERT(datetime, SWITCHOFFSET(CONVERT(DATETIMEOFFSET, CreatedUTC), DATENAME(TZOFFSET, SYSDATETIMEOFFSET())))
                AS  AT_TS_ALLOTMENT_CREATED,
	        CONVERT(datetime, SWITCHOFFSET(CONVERT(DATETIMEOFFSET, VersionStartUTC), DATENAME(TZOFFSET, SYSDATETIMEOFFSET())))
	            AS AT_TS_ALLOTMENT_MODIFED,
            MOVE_SALES as AT_CD_STATUS,
	        DT_CONFUTC AS AT_DT_CONFIRMED ,
	        PnrConf AS  AT_CD_PNR_CONFIRMED,
	        InventoryLegid AS ID_INVENTORY_LEG,
            GETDATE()  AS TS_CREATION,
	        GETDATE()  AS TS_MODIFIED
    FROM
        (
	        SELECT
				il.inventorylegid,
				ilc.ClassOfService,
				ilc.ClassAllotted - coalesce(lag(ilc.ClassAllotted) over (partition by ilc.InventoryLegID, ilc.ClassNest, ilc.ClassOfService order by VersionStartUTC),0)
				    AS PAX,
				il.FlightNumber,
				il.DepartureDate,
				il.DepartureStation,
				il.ArrivalStation,
				ag.agentname,
				ilc.CreatedUTC,
				ilc.VersionStartUTC,
				(CASE WHEN ilc.ClassAllotted = 0 THEN  -1 ELSE 0 END) AS MOVE_SALES,
				NULL DT_CONFUTC,
				NULL PnrConf,
				ilc.ClassNest
			FROM
				dbo.InventoryLeg il with(nolock)
				INNER JOIN Rez.InventoryLegNest iln with(nolock) ON il.inventorylegid = iln.inventorylegid
				INNER JOIN ODS_DATABASE.InventoryLegClassVersion ilc with(nolock) ON iln.inventorylegid = ilc.inventorylegid
						AND iln.ClassNest = ilc.ClassNest
				INNER JOIN REZ.AGENT AG with(nolock)
					ON il.ModifiedAgentID = AG.AGENTID
			JOIN vueling_calcods.[dbo].[stg_Allotment_gral]al on ilc.ClassOfService=  al.ClassOfService and ilc.InventoryLegID =al.InventoryLegID
			WHERE  ilc.ClassType = 'N'  AND il.CarrierCode = 'VY' and  ilc.VersionStartUTC>='2022-10-04 00:00:00.000'
			UNION
			SELECT  inventorylegid,
				    AT_ALLOTMENT_NAME,
					CA_PAX,
					AT_FLIGHT_NUMBER,
					AT_DT_FLIGHT,
					AT_AIRPORT_DEP,
					AT_AIRPORT_ARR,
					AT_AGENT_NAME,
					TS_ALLORMENT_CREATEDUTC,
					TS_ALLOTMENT_MODIFEDUTC,
					AT_MOVE_SALES,
					AT_DT_CONFUTC,
					PnrConf,
					ClassNest
			FROM vueling_calcods.dbo.stg_AllPax_gral
    )New_Allotment
    WHERE pax<>0;