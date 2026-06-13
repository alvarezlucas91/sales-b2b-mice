SELECT DISTINCT b.RecordLocator                as RecordLocator,
                cast(b.CreatedUTC as date)     as CreatedDate,
                brl.RecordCode                 as OARecordLocator,
                brl.BookingSystemCode          as BookingSystemCode,
                brl.SystemDomainCode           as SystemDomainCode,
                b.SourceDomainCode             as SourceDomainCode,
                p.PaymentAmount                as PaymentAmount,
                p.PaymentMethodCode            as PaymentMethodCode,
                CASE b.Status
                    WHEN 0 THEN 'Default'
                    WHEN 1 THEN 'Hold'
                    WHEN 2 THEN 'Confirmed'
                    WHEN 3 THEN 'Closed'
                    WHEN 4 THEN 'HoldCanceled'
                    WHEN 5 THEN 'PendingArchive'
                    WHEN 6 THEN 'Archived' END as BookingStatus,
                CASE p.Status
                    WHEN 1 THEN 'Pending'
                    WHEN 2 THEN 'Under Paid'
                    WHEN 3 THEN 'Paid In Full'
                    WHEN 4 THEN 'Over Paid'
                    WHEN 6 THEN 'Pending Customer Action'
                    END                        as PaidStatus,
                pjs.DepartureDate              as DepartureDate,
                il.FlightNumber                as FlightNumber,
                il.DepartureStation            as DepartureStation,
                il.ArrivalStation              as ArrivalStation,
                pjs.ProductClassCode           as ProductClassCode,
                CASE pjs.SegmentType
                    WHEN 'C' THEN 'Operating'
                    WHEN 'L' THEN 'Marketing'
                    WHEN 'O' THEN 'InterlineOUT'
                    WHEN 'I' THEN 'InterlineIN'
                    WHEN 'P' THEN 'Passive'
                    ELSE 'Prime'
                    END                        as SegmentType,
                b.SourceUserCode               as SourceUserCode,
                pjs.PassengerID                as PassengerID,
                bp.LastName                    as LastName,
                bp.FirstName                   as FirstName,
                CASE pjl.LiftStatus
                    WHEN '0' THEN 'Default'
                    WHEN '1' THEN 'Checkin'
                    WHEN '2' THEN 'Boarded'
                    WHEN '3' THEN 'NoShow'
                    END                        AS LiftStatus,
                pjs.TicketNumber               as TicketNumber


FROM REZ.booking b with (nolock)
         JOIN rez.BookingRecordLocator brl with (nolock) on brl.BookingID = b.BookingID
         JOIN REZ.bookingpassenger bp with (nolock) ON b.bookingid = bp.bookingid
         JOIN REZ.passengerjourneysegment pjs with (nolock) ON bp.passengerid = pjs.passengerid

         JOIN REZ.passengerjourneyleg pjl with (nolock)
              ON bp.passengerID = pjl.passengerID AND pjs.segmentID = pjl.segmentID
         JOIN REZ.inventoryleg il with (nolock) ON pjl.inventorylegID = il.inventorylegID

         JOIN rez.Payment p with (nolock) ON p.BookingID = B.BookingID
WHERE 1 = 1
  AND pjs.TicketNumber = '' --# sin eTicket
  AND b.ChannelType = 3     -- GDS
  AND cast(b.CreatedUTC as date ) BETWEEN '{0}' AND '{1}'
  AND p.PaymentMethodCode = 'AG'
  AND p.Status in (3, 4)
  AND pjs.SegmentType = ''
