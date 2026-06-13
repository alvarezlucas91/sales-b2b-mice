SELECT
  EXTRA_SEATS.DEPARTURE_DATE,
  EXTRA_SEATS.ID_VUELO,
  EXTRA_SEATS.STD,
  EXTRA_SEATS.STA,
  EXTRA_SEATS.PNR,
  EXTRA_SEATS.FIRST_NAME,
  EXTRA_SEATS.LAST_NAME,
  EXTRA_SEATS.STATUS_CHECK,
  EXTRA_SEATS.SEAT,
  EXTRA_SEATS.SEAT2
FROM
  (
    select
        il.departuredate DEPARTURE_DATE,
        SUBSTRING(il.inventorylegkey, 10, LEN(il.inventorylegkey)) as ID_VUELO,
		LEFT(CONVERT(varchar,il.std, 108),5) AS STD,
		LEFT(CONVERT(varchar,il.sta, 108),5) AS STA,
        b.RecordLocator PNR,
        bp.FirstName FIRST_NAME,
        bp.LastName LAST_NAME,
        case pjl.LiftStatus
            when 1 then 'CheckedIn'
            when 2 then 'Boarded'
            when 3 then 'NoShow'
        else 'No'  end as STATUS_CHECK,
        pjl.unitdesignator as SEAT,
        pjl2.unitdesignator as SEAT2
    from
        REZ.Booking b with(nolock)
            inner join REZ.BookingPassenger bp with(nolock)on bp.BookingID = b.BookingID
            inner join REZ.PassengerJourneySegment pjs with(nolock)on pjs.PassengerID = bp.PassengerID
            inner join REZ.PassengerJourneyLeg pjl with(nolock)on pjl.PassengerID = pjs.PassengerID and pjl.SegmentID = pjs.SegmentID
            inner join REZ.InventoryLeg il with(nolock)on il.InventoryLegID = pjl.InventoryLegID
            left join REZ.BookingPassenger bp2 with(nolock)on bp2.BookingID = b.BookingID and bp2.passengerID<>bp.passengerID and bp2.firstName=bp.firstName and bp2.middleName=bp.middleName and bp2.lastName=bp.lastName
            left join REZ.PassengerJourneyLeg pjl2 with(nolock)on pjl2.PassengerID = bp2.passengerId and il.InventoryLegID = pjl2.InventoryLegID
    where
	    exists (select distinct PassengerID
		        from REZ.PassengerJourneySSRVersion pjssrv with(nolock)
		        where SSRCode = 'EXST' and pjssrv.PassengerID = pjl.PassengerID  and pjssrv.SegmentID = pjl.SegmentID)
	    and cast(il.DepartureDate as date) between '{0}' and '{1}'
) EXTRA_SEATS
order by DEPARTURE_DATE