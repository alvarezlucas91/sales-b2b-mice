truncate table vueling_calcods.dbo.stg_clAllotments;

insert into vueling_calcods.dbo.stg_clAllotments (
                                                ClassOfService,
                                                InventoryLegID
                                                )
    SELECT ilcv.ClassOfService,ilcv.InventoryLegID
		       FROM
				( SELECT ROW_NUMBER() over (PARTITION BY cv.classofservice,cv.inventorylegid order by VersionEndUTC desc) AS ID ,
						 cv.classofservice,cv.inventorylegid,cv.ClassAllotted,cv.ClassNest,
						  cv.ClassType,cv.CreatedUTC,
						   cv.ModifiedUTC,cv.VersionStartUTC,cv.VersionEndUTC,DeletedUserID
 					FROM ODS_DATABASE.InventoryLegClassVersion cv WITH(NOLOCK)
						INNER JOIN vueling_calcods.[dbo].[stg_Allotment_gral] Al
			 	  		    ON Al.ClassofService = cv.ClassOfService AND Al.InventoryLegID = cv.InventoryLegID
					WHERE ClassType = 'N' and  CreatedUTC>='2022-10-04 00:00:00.000'
                  ) ilcv
				  LEFT JOIN  Rez.InventoryLegClass ilc with(nolock)
					    ON ilcv.InventoryLegID = ilc.InventoryLegID and ilcv.ClassOfService = ilc.ClassOfService
				  WHERE id=1 and ilc.ClassOfService is null;


truncate table vueling_calcods.dbo.stg_clClassAllotments_gral;
insert into vueling_calcods.dbo.stg_clClassAllotments_gral
                                                        (
	                                                        inventorylegid
	                                                        ,ClassOfService
	                                                        ,CA_PAX
	                                                        ,FlightNumber
	                                                        ,DepartureDate
	                                                        ,DepartureStation
	                                                        ,ArrivalStation
	                                                        ,AGENTNAME
	                                                        ,CreatedUTC
	                                                        ,VersionStartUTC
	                                                        ,MOVE_SALES
	                                                        ,DT_CONFUTC
	                                                        ,PnrConf
	                                                    )
    SELECT
		il.inventorylegid,
		ilcv.ClassOfService,
		ilcv.ClassAllotted - coalesce(lag(ilcv.ClassAllotted) over (partition by ilcv.InventoryLegID, ilcv.ClassNest, ilcv.ClassOfService order by VersionStartUTC),0) as CA_PAX,
		il.FlightNumber,
		il.DepartureDate,
		il.DepartureStation,
		il.ArrivalStation,
		AG.AGENTNAME,
		ilcv.CreatedUTC,
		ilcv.VersionStartUTC,
				 (CASE WHEN ilc.ClassAllotted = 0 THEN  -1 ELSE 0 END) as MOVE_SALES,
				  NULL DT_CONFUTC,
				  NULL PnrConf
        	FROM
				dbo.InventoryLeg il with(nolock)
				INNER JOIN Rez.InventoryLegNest iln with(nolock) ON il.inventorylegid = iln.inventorylegid
				INNER JOIN ODS_DATABASE.InventoryLegClassVersion ilcv with(nolock) ON iln.inventorylegid = ilcv.inventorylegid
						AND iln.ClassNest = ilcv.ClassNest
	             INNER JOIN vueling_calcods.[dbo].[stg_Allotment_gral] Al
			 	   ON Al.ClassofService = ilcv.ClassOfService AND Al.InventoryLegID = ilcv.InventoryLegID
				INNER JOIN REZ.AGENT AG
					ON il.ModifiedAgentID = AG.AGENTID
				LEFT JOIN Rez.InventoryLegClass ilc with(NOLOCK)
					ON ilc.InventoryLegID = ilcv.InventoryLegID and ilc.ClassOfService = ilcv.classofservice AND ilc.ModifiedUTC = ilcv.ModifiedUTC
				WHERE  ilcv.ClassType = 'N'  AND il.CarrierCode = 'VY' and ilcv.VersionStartUTC>='2022-10-04 00:00:00.000'
				AND ilc.ClassOfService is null
				AND EXISTS (SELECT 1
							FROM vueling_calcods.dbo.stg_clAllotments CL
  							WHERE ILCV.CLASSOFSERVICE = CL.CLASSOFSERVICE AND ILCV.INVENTORYLEGID = CL.INVENTORYLEGID );

insert into vueling_calcods.dbo.stg_clClassAllotments_gral
                         (
	                                                        inventorylegid
	                                                        ,ClassOfService
	                                                        ,CA_PAX
	                                                        ,FlightNumber
	                                                        ,DepartureDate
	                                                        ,DepartureStation
	                                                        ,ArrivalStation
	                                                        ,AGENTNAME
	                                                        ,CreatedUTC
	                                                        ,VersionStartUTC
	                                                        ,MOVE_SALES
	                                                        ,DT_CONFUTC
	                                                        ,PnrConf
	                                                    )

    SELECT  il.inventorylegid,
				ilcv.ClassOfService,
				-ilcv.ClassAllotted,
				il.FlightNumber,
				il.DepartureDate,
				il.DepartureStation,
				il.ArrivalStation,
				ag.AgentName,
				ilcv.CreatedUTC,
				ilcv.VersionStartUTC,
				 -1  as MOVE_SALES,
				 NULL DT_CONFUTC,
				NULL PnrConf
	FROM  dbo.InventoryLeg il with(nolock)
	INNER JOIN Rez.InventoryLegNest iln with(nolock) ON il.inventorylegid = iln.inventorylegid
	INNER JOIN REZ.AGENT AG
		  ON il.ModifiedAgentID = AG.AGENTID
	JOIN (SELECT ROW_NUMBER() over (PARTITION BY icv.classofservice,icv.inventorylegid order by icv.ModifiedUTC desc) AS ID ,
						   icv.classofservice,icv.inventorylegid,icv.ClassAllotted,icv.ClassNest,icv.ClassType,icv.CreatedUTC,icv.ModifiedUTC,icv.VersionStartUTC
 						   FROM ODS_DATABASE.InventoryLegClassVersion icv  WITH(NOLOCK)
                                   INNER JOIN vueling_calcods.[dbo].[stg_Allotment_gral]  Al
			 	               ON Al.ClassofService = icv.ClassOfService AND Al.InventoryLegID = icv.InventoryLegID
						   where ClassType = 'N' and  CreatedUTC>='2022-10-04 00:00:00.000'
	   ) ilcv
	 ON iln.inventorylegid = ilcv.inventorylegid AND iln.ClassNest = ilcv.ClassNest AND ID=1
	 LEFT JOIN Rez.InventoryLegClass ilc with(NOLOCK)
					ON ilc.InventoryLegID = ilcv.InventoryLegID and ilc.ClassOfService = ilcv.classofservice AND ilc.ModifiedUTC = ilcv.ModifiedUTC
	WHERE ilc.ClassOfService is null
	AND EXISTS (SELECT 1
					FROM vueling_calcods.dbo.stg_clAllotments CL
  					WHERE ILCV.CLASSOFSERVICE = CL.CLASSOFSERVICE AND ILCV.INVENTORYLEGID = CL.INVENTORYLEGID );




