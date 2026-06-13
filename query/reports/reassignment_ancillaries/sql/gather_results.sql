select RecordLocator,
       LastName,
       CreatedBooking,
       ClassOfService,
       FlightNumber,
       DepartureDate,
       CarrierCode,
       DepartureStation,
       ArrivalStation,
       SSRCode,
       CreateFee,
       ModifiedUTC, [Status], Deleted
from {0} rs
order by bookingid asc, Deleted desc