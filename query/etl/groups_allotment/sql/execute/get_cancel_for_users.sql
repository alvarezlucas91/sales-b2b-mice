SELECT ClassOfService   as at_cd_allotment_name,
       FlightNumber     as at_cd_flight_number,
       DepartureDate    as at_dt_flight,
       DepartureStation as at_cd_airport_dep,
       ArrivalStation   as at_cd_airport_arr,
	   AgentName        as at_cd_organization,
	  (CASE
	       WHEN (MOV = -2
                    AND coalesce(lag(ClassAllotted)
                             over(partition by InventoryLegID, ClassNest, ClassOfService order by ModifiedUTC), 0) = 0
                    AND    coalesce(lead(Mov) over(partition by InventoryLegID, ClassNest, ClassOfService
                            order by ModifiedUTC), 0) =-1)
                    THEN ClassAllotted
            WHEN MOV = -2  THEN
                - coalesce(lag(ClassAllotted)
                           over(partition by InventoryLegID, ClassNest, ClassOfService order by ModifiedUTC), 0)
            WHEN (coalesce(lag(Mov) over(partition by InventoryLegID, ClassNest, ClassOfService
                    order by ModifiedUTC), 0) = -1)
                THEN ClassAllotted
            ELSE
                ClassAllotted - coalesce(lag(ClassAllotted)
                                         over(partition by InventoryLegID, ClassNest, ClassOfService
                                         order by ModifiedUTC),0)
           END) ca_pax,
       CONVERT(datetime, SWITCHOFFSET(CONVERT(DATETIMEOFFSET, CreatedUTC),
               DATENAME(TZOFFSET, SYSDATETIMEOFFSET()))) as at_ts_allotment_created,
       CONVERT(datetime, SWITCHOFFSET(CONVERT(DATETIMEOFFSET, ModifiedUTC),
                                      DATENAME(TZOFFSET, SYSDATETIMEOFFSET()))) as at_ts_allotment_modifed,
       (CASE WHEN ( Mov=0 and lead(Mov) over(partition by InventoryLegID, ClassNest, ClassOfService
                            order by ModifiedUTC) IS NULL AND  DepartureDate<CAST(GETDATE() AS DATE) )THEN -2
			ELSE Mov end ) AS at_cd_status,
       NULL  AS  at_dt_confirmed,
       NULL AS at_cd_pnr_confirmed,
	   InventoryLegid AS id_inventory_leg,
	   GETDATE()  AS ts_creation,
	   GETDATE()  AS ts_modified
FROM (SELECT InventoryLegid,
             ClassOfService,
             ClassAllotted,
             FlightNumber,
             DepartureDate,
             DepartureStation,
             ArrivalStation,
			 AgentName,
             CreatedUTC,
             (CASE WHEN DT_PNRCONF IS NOT NULL THEN DT_PNRCONF ELSE ModifiedUTC END) ModifiedUTC,
             ClassNest,
             DeletedUserID,
             mov,
             DT_PNRCONF
      FROM (SELECT il.inventorylegid,
                   ilcv.ClassOfService,
                   ilcv.ClassAllotted,
                   il.FlightNumber,
                   il.DepartureDate,
                   il.DepartureStation,
                   il.ArrivalStation,
                   ilcv.CreatedUTC      AS CreatedUTC,
                   ilcv.VersionStartUTC as ModifiedUTC,
                   iln.ClassNest,
                   ilcv.DeletedUserID,
				   AG.AgentName,
                   (CASE
                        WHEN ilcv.ClassAllotted = 0 OR DELETEDUSERID IS NOT NULL THEN -2
                        ELSE 0 END)        MOV,
                   NULL                    DT_PNRCONF
            FROM VUELING_NAVITAIRE.dbo.InventoryLeg il with(nolock)
								INNER JOIN VUELING_NAVITAIRE.Rez.InventoryLegNest iln	with (nolock)
					ON il.inventorylegid = iln.inventorylegid
                INNER JOIN VUELING_NAVITAIRE.ODS_DATABASE.InventoryLegClassVersion ilcv with (nolock)
					ON iln.inventorylegid = ilcv.inventorylegid AND iln.ClassNest = ilcv.ClassNest
				INNER JOIN VUELING_NAVITAIRE.REZ.AGENT AG with(nolock)
					ON il.ModifiedAgentID = AG.AGENTID
                  INNER JOIN vueling_calcods.[dbo].[stg_Allotment_gral] Al
                    ON ilcv.InventoryLegID = al.InventoryLegID and ilcv.ClassOfService = al.ClassOfService
                LEFT JOIN VUELING_NAVITAIRE.REZ.InventoryLegClass ilc with (NOLOCK)
					ON ilc.InventoryLegID = ilcv.InventoryLegID and ilc.ClassOfService = ilcv.classofservice
						and ilc.ModifiedUTC = ilcv.ModifiedUTC
            WHERE EXISTS ( SELECT 1
							FROM Vueling_Navitaire.ODS_DATABASE.InventoryLegClassVersion cl with (NOLOCK)
								inner join Vueling_Navitaire.REZ.InventoryLeg il with (NOLOCK)
									ON cl.inventorylegid = il.inventorylegid
                                INNER JOIN vueling_calcods.[dbo].[stg_Allotment_gral] Al
                                    ON ilcv.InventoryLegID = al.InventoryLegID and ilcv.ClassOfService = al.ClassOfService
							WHERE cl.ClassType = 'N'
									and cl.VersionStartUTC >='2022-10-04 00:00:00.000'
									AND IL.CARRIERCODE ='VY'
									AND CL.DeletedUserID IS NOT NULL
									and ilcv.classofservice = CL.ClassOfService
									AND ilcv.InventoryLegID = cl.InventoryLegID)

									) A
) CAL;
