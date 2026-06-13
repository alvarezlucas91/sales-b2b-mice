TRUNCATE table vueling_calcods.dbo.stg_SegmentVersion_gral;

INSERT INTO vueling_calcods.dbo.stg_SegmentVersion_gral ( ClassOfService,
                                                        passengerid,
                                                        BookingUTC,
                                                        ModifiedUTC,
                                                        InventoryLegID,
                                                        RecordLocator,
                                                        segmentid,
                                                        VersionStartUTC,
                                                        VersionEndUTC
                                                       )
    SELECT  distinct ilc.ClassOfService,bp.passengerid,b.BookingUTC,ilc.ModifiedUTC,
        ilc.InventoryLegID,b.RecordLocator,
        pjs.segmentid,pjs.VersionStartUTC,pjs.VersionEndUTC
    FROM REZ.booking b with(nolock)
        INNER JOIN  Rez.bookingpassenger bp with(nolock)
	        ON b.bookingid = bp.bookingid
        INNER JOIN  Rez.PassengerJourneySegmentVersion pjs with(nolock)
	        ON bp.passengerid = pjs.passengerid
        JOIN vueling_calcods.[dbo].[stg_Allotment_gral] ilc
  	        ON pjs.ClassOfService = ilc.ClassOfService
        INNER JOIN ODS_DATABASE.InventoryLegClassSold cs
	        ON cs.ClassOfService = ilc.ClassOfService and cs.InventoryLegID=ilc.InventoryLegID
    WHERE b.BookingParentID=0 and cs.ClassSold>0;

TRUNCATE TABLE vueling_calcods.dbo.stg_SalesPax_Hi_gral;
INSERT INTO vueling_calcods.dbo.stg_SalesPax_Hi_gral (inventoryLegID,
                                                    at_Allotment,
                                                    DateAllotmentModifiedUTC,
                                                    AT_DT_CONFUTC,
                                                    PnrConf,
                                                    NumPaxVendidos
                                                    )
    SELECT  sv.inventorylegid,
            sv.ClassOfService as at_Allotment,
            sv.ModifiedUTC AS DateAllotmentModifiedUTC,
            sv.BookingUTC as AT_DT_CONFUTC,
            sv.recordlocator as PnrConf,
            count(distinct sv.passengerid)NumPaxVendidos
     FROM Rez.PassengerJourneyLegVersion pjl with(nolock)
     JOIN vueling_calcods.dbo.stg_SegmentVersion_gral sv
		  ON sv.passengerid = pjl.passengerid AND sv.segmentid = pjl.segmentid
	      and pjl.VersionStartUTC between sv.VersionStartUTC and sv.VersionEndUTC
        and pjl.createdutc>='2022-10-04 00:00:00.000'
    GROUP BY sv.inventorylegid,sv.ClassOfService,sv.ModifiedUTC,sv.BookingUTC,sv.recordlocator;