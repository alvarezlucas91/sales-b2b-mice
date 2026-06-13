TRUNCATE TABLE vueling_calcods.[dbo].[stg_Allotment_gral];

INSERT INTO vueling_calcods.[dbo].[stg_Allotment_gral]
                                                    (
                                                     ClassOfService
                                                     ,InventoryLegID
                                                     ,ModifiedUTC
                                                    )
    SELECT ILC.ClassOfService,il.InventoryLegID,ilc.ModifiedUTC
    FROM
	    dbo.InventoryLeg il with(nolock)
	   INNER JOIN Rez.InventoryLegNest iln with(nolock)
	   		ON il.inventorylegid = iln.inventorylegid
		INNER JOIN ODS_DATABASE.InventoryLegClass ilc with(nolock)
			ON iln.inventorylegid = ilc.inventorylegid
				AND iln.ClassNest = ilc.ClassNest
		INNER JOIN REZ.AGENT AG with(nolock)
			ON il.ModifiedAgentID = AG.AGENTID
	    WHERE  ilc.ClassType = 'N'  AND il.CarrierCode = 'VY'
	        and CAST(ilc.ModifiedUTC AS DATE) between  '{0}' and '{1}'
	 ORDER BY ILC.ClassOfService,il.InventoryLegID;



INSERT INTO vueling_calcods.[dbo].[stg_Allotment_gral]
                                                    (
                                                     ClassOfService
                                                    ,InventoryLegID
                                                    ,ModifiedUTC
                                                    )
    SELECT ILC.ClassOfService,il.InventoryLegID,
            MAX(ilc.ModifiedUTC) as ModifiedUTC
    FROM
	    dbo.InventoryLeg il with(nolock)
	   INNER JOIN ODS_DATABASE.InventoryLegNest  iln with(nolock)
	   		ON il.inventorylegid = iln.inventorylegid
		INNER JOIN ODS_DATABASE.InventoryLegClassVersion ilc with(nolock)
			ON iln.inventorylegid = ilc.inventorylegid
				AND iln.ClassNest = ilc.ClassNest
		INNER JOIN REZ.AGENT AG with(nolock)
			ON il.ModifiedAgentID = AG.AGENTID
	    WHERE  ilc.ClassType = 'N'  AND il.CarrierCode = 'VY'
		    and CAST(ilc.ModifiedUTC AS DATE)  between  '{0}' and '{1}'
        AND NOT EXISTS (SELECT 1 FROM vueling_calcods.[dbo].[stg_Allotment_gral] A
                    WHERE A.ClassOfService= ILC.ClassOfService
					AND A.InventoryLegID=il.InventoryLegID)
		GROUP BY ILC.ClassOfService,il.InventoryLegID
        ORDER BY  ILC.ClassOfService,il.InventoryLegID;


INSERT INTO  vueling_calcods.[dbo].[stg_Allotment_gral]
                                                    (
                                                     ClassOfService
                                                    ,InventoryLegID
                                                    ,ModifiedUTC
                                                    )
SELECT ILC.ClassOfService,il.InventoryLegID,
        MAX(cs.ModifiedUTC) as ModifiedUTC
    FROM
	    dbo.InventoryLeg il with(nolock)
	   INNER JOIN ODS_DATABASE.InventoryLegNest  iln with(nolock)
	   		ON il.inventorylegid = iln.inventorylegid
		INNER JOIN ODS_DATABASE.InventoryLegClassVersion ilc with(nolock)
			ON iln.inventorylegid = ilc.inventorylegid AND iln.ClassNest = ilc.ClassNest
		JOIN Vueling_Navitaire.ODS_DATABASE.inventoryLegClassSold cs
		 on ilc.InventoryLegID = cs.InventoryLegID and cs.ClassOfService = ilc.ClassOfService
		INNER JOIN REZ.AGENT AG with(nolock)
			ON il.ModifiedAgentID = AG.AGENTID
	    WHERE  ilc.ClassType = 'N'  AND il.CarrierCode = 'VY'
		    and CAST(cs.ModifiedUTC AS DATE)  between '{0}' and '{1}'
	    AND NOT EXISTS (SELECT 1 FROM  vueling_calcods.[dbo].[stg_Allotment_gral] A
                    WHERE A.ClassOfService= ILC.ClassOfService
					AND A.InventoryLegID=il.InventoryLegID)
		GROUP BY ILC.ClassOfService,il.InventoryLegID
        ORDER BY  ILC.ClassOfService,il.InventoryLegID;
