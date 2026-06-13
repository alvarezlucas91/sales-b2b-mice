INSERT INTO {0}
SELECT B.RecordLocator,
       B.BookingID,
       BP.LastName,
       B.CreatedUTC  as CreatedBooking,
       pjs.ClassOfService,
       PJS.PassengerID,
       pjs.SegmentID,
       SR.SSRCode,
       SR.CreatedUTC as CreatedFee,
       SR.ModifiedUTC,
       'Add' [Status], NULL Deleted
FROM VUELING_NAVITAIRE.REZ.BOOKING B
WITH (NOLOCK)
    JOIN VUELING_NAVITAIRE.REZ.BookingPassenger BP
WITH (NOLOCK)
on b.bookingid=bp.BookingID
    JOIN VUELING_NAVITAIRE.Rez.PassengerJourneySegment pjs
WITH (NOLOCK)
ON BP.PassengerID = pjs.PassengerID
    JOIN VUELING_NAVITAIRE.REZ.PassengerJourneySSR SR
WITH (NOLOCK)
ON SR.PassengerID = PJS.PassengerID AND SR.segmentid = pjs.SegmentID
    JOIN {1} fc
    ON fc.BookingID = b.BookingID and sr.SSRCode = fc.SSRCode and
    CAST (SR.CreatedUTC AS DATE) >= cast (fc.Deleted as date)