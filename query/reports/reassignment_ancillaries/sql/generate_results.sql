INSERT INTO  {0}
SELECT RecordLocator,
       BookingID,
       LastName,
       CreatedBooking,
       ClassOfService,
       passengerid,
       FlightNumber,
       DepartureDate,
       CarrierCode,
       DepartureStation,
       ArrivalStation,
       ssrcode,
       createfee,
       ModifiedUTC, [Status], Deleted
FROM (
    SELECT cf.RecordLocator, BookingID, CF.LastName, CreatedBooking, ClassOfService, cf.passengerid, il.FlightNumber, il.DepartureDate, il.CarrierCode, il.DepartureStation, il.ArrivalStation, cf.ssrcode, cf.createfee, cf.ModifiedUTC, cf.[Status], cf.Deleted
    FROM {1} cf
    JOIN VUELING_NAVITAIRE.REZ.PassengerJourneyleg pjl WITH (NOLOCK)
    ON cf.passengerid = pjl.PassengerID and cf.SegmentID= pjl.SegmentID
    JOIN VUELING_NAVITAIRE.REZ.InventoryLeg il
    on pjl.InventoryLegID = il.InventoryLegID
    where CarrierCode ='VY'
    AND EXISTS ( SELECT 1 FROM {2} ad where ad.BookingID= cf.BookingID)
    union
    SELECT af.RecordLocator, af.BookingID, af.LastName, af.CreatedBooking, af.ClassOfService, af.passengerid, il.FlightNumber, il.DepartureDate, il.CarrierCode, il.DepartureStation, il.ArrivalStation, af.ssrcode, af.CreatedFee, af.ModifiedUTC, af.[Status], af.Deleted
    from {2} af
    JOIN VUELING_NAVITAIRE.REZ.PassengerJourneyleg pjl WITH (NOLOCK)
    ON af.passengerid = pjl.PassengerID and af.SegmentID= pjl.SegmentID
    JOIN VUELING_NAVITAIRE.REZ.InventoryLeg il
    on pjl.InventoryLegID = il.InventoryLegID
    where CarrierCode ='VY'
    AND EXISTS ( SELECT 1 FROM {1} cd where cd.BookingID= cd.BookingID)
    ) alt