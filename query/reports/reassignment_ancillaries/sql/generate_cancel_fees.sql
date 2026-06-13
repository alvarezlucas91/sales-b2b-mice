INSERT INTO {0}
SELECT B.RecordLocator,
       B.BookingID,
       BP.LastName,
       B.CreatedUTC  as CreatedBooking,
       pjs.ClassOfService,
       PJS.PassengerID,
       pjs.SegmentID,
       SR.SSRCode,
       SR.CreatedUTC as CreateFee,
       SR.ModifiedUTC,
       (case when SR.VersionEndUTC <> '9999-12-31 00:00:00.000' then 'Removed' else '' end) [Status],
        SR.VersionEndUTC as Deleted
FROM Vueling_Navitaire.REZ.BOOKING B
WITH (NOLOCK)
    JOIN Vueling_Navitaire.rez.BookingPassenger BP
WITH (NOLOCK)
on b.bookingid=bp.BookingID
    JOIN Vueling_Navitaire.Rez.PassengerJourneySegment pjs
WITH (NOLOCK)
ON BP.PassengerID = pjs.PassengerID
    JOIN Vueling_Navitaire.REZ.PassengerJourneySSRVersion SR
WITH (NOLOCK)
ON SR.PassengerID = PJS.PassengerID AND SR.segmentid = pjs.SegmentID
WHERE SR.VersionEndUTC <> '9999-12-31 00:00:00.000'
  and exists (select 1 from {1} al where al.ClassOfService =pjs.ClassOfService)