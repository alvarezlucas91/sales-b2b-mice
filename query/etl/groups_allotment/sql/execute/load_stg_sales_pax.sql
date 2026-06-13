TRUNCATE TABLE vueling_calcods.dbo.stg_SalesPax_gral;

INSERT INTO vueling_calcods.dbo.stg_SalesPax_gral
                                            (
                                                inventoryLegID,
                                                at_Allotment,
                                                DateAllotmentModifiedUTC,
                                                AT_DT_CONFUTC,
                                                PnrConf,
                                                NumPaxVendidos
                                            )
    SELECT  ilc.inventoryLegID,
        ilc.ClassOfService AS at_Allotment,
        ilc.ModifiedUTC AS DateAllotmentModifiedUTC,
	    b.BookingUTC AS AT_DT_CONFUTC,
	    b.recordlocator AS PnrConf,
	    COUNT(DISTINCT BP.PASSENGERID) AS NumPaxVendidos
    FROM REZ.booking b with(nolock)
	    INNER JOIN  Rez.bookingpassenger bp with(nolock)
		    ON b.bookingid = bp.bookingid
	    INNER JOIN  Rez.PassengerJourneySegment pjs with(nolock)
		    ON bp.passengerid = pjs.passengerid
	    INNER JOIN  Rez.PassengerJourneyLeg pjl with(nolock)
		    ON bp.passengerid = pjl.passengerid AND pjs.segmentid = pjl.segmentid
	    JOIN vueling_calcods.[dbo].[stg_Allotment_gral] ilc
  	        ON pjs.ClassOfService = ilc.ClassOfService
        INNER JOIN ODS_DATABASE.InventoryLegClassSold cs
		    ON cs.ClassOfService = ilc.ClassOfService and cs.InventoryLegID=ilc.InventoryLegID
	WHERE b.BookingParentID = 0 and cs.ClassSold>0
   GROUP BY ilc.inventoryLegID,ilc.ClassOfService,
            ilc.ModifiedUTC, b.BookingUTC, b.recordlocator;
