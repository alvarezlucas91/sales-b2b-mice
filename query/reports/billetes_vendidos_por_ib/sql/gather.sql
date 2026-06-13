SELECT DISTINCT x.PaxNumber                        AS PaxNumber
              , bp.TotalCost                       AS PaxTotalCost
              , bp.TotalCost * x.PaxNumber         AS TotalCost
              , b.RecordLocator
              , brl.RecordCode                     AS RecordLocatorIberia
              , CONVERT(varchar, b.CreatedUTC, 23) AS CreationDate
              , CASE b.Status
                    WHEN 0 THEN 'Default'
                    WHEN 1 THEN 'Hold'
                    WHEN 2 THEN 'Confirmed'
                    WHEN 3 THEN 'Closed'
                    WHEN 4 THEN 'HoldCanceled'
                    WHEN 5 THEN 'PendingArchive'
                    WHEN 6 THEN 'Archived'
    END                                            AS bStatus
              , b.SystemCode
              , CASE b.ChannelType
                    WHEN 1 THEN 'SKSP'
                    WHEN 2 THEN 'WEB'
                    WHEN 3 THEN 'GDS'
                    WHEN 4 THEN 'API'
    END                                            AS Channel
              , b.SourceUserCode
              , bc.AddressLine2
              , b.SourceLocationCode
              , pjs.XRefCarrierCode
              , pjs.ProductClassCode
              , CASE pjs.SegmentType
                    WHEN 'C' THEN 'Operating'
                    WHEN 'L' THEN 'Marketing'
                    WHEN 'O' THEN 'InterlineOUT'
                    WHEN 'I' THEN 'InterlineIN'
                    WHEN 'P' THEN 'Passive'
                    ELSE 'Prime'
    END
                                                   AS 'SegmType'
              , pjl.BookingStatus
              , il.DepartureDate
              , il.CarrierCode
              , il.FlightNumber
              , il.DepartureStation
              , il.ArrivalStation
              , CASE il.Status
                    WHEN 0 THEN 'Open'
                    WHEN 1 THEN 'Closed'
                    WHEN 2 THEN 'Canceled'
                    WHEN 3 THEN 'Suspended'
                    WHEN 5 THEN 'ClosePending'
                    WHEN 6 THEN 'BlockAllActivities'
    END                                            AS LegStatus
              , bp.PassengerID
              , bp.LastName
              , bp.FirstName
              , pjs.TicketNumber
              , CASE pjl.LiftStatus
                    WHEN '0' THEN 'Default'
                    WHEN '1' THEN 'Checkin'
                    WHEN '2' THEN 'Boarded'
                    WHEN '3' THEN 'NoShow'
    END                                            AS LiftStatus
              , bcc.CommentText                    AS Comment
              , bcc.CommentType                    AS CommentType

FROM REZ.booking b with (nolock)
         INNER JOIN REZ.BookingContact bc with (nolock) ON b.bookingid = bc.bookingid
         INNER JOIN REZ.bookingpassenger bp with (nolock) ON b.bookingid = bp.bookingid
         INNER JOIN REZ.BookingRecordLocator brl with (nolock) ON b.bookingid = brl.bookingid -- PNR emitidos
         INNER JOIN REZ.passengerjourneysegment pjs with (nolock) ON bp.passengerid = pjs.passengerid
         INNER JOIN (SELECT bp.bookingid, count(bp.PassengerID) as PaxNumber
                     FROM REZ.bookingpassenger bp
                     GROUP BY bp.bookingid) x
                    ON x.BookingID = b.BookingID
         INNER JOIN REZ.passengerjourneyleg pjl with (nolock)
                    ON bp.passengerID = pjl.passengerID AND pjs.segmentID = pjl.segmentID
         INNER JOIN REZ.inventoryleg il with (nolock) ON pjl.inventorylegID = il.inventorylegID
         JOIN REZ.BookingComment bcc with (nolock) ON bcc.BookingID = b.BookingID
WHERE pjs.XRefCarrierCode = 'IB' -- Vendidos por Iberia
  AND pjs.SegmentType = 'C'      -- Marketing Codeshare
  AND pjs.ProductClassCode NOT LIKE 'L%'
  AND pjs.TicketNumber = ''      --# sin eTicket
  AND bc.TypeCode = 'A'
  AND b.CreatedUTC BETWEEN '{0}' AND '{1}'
ORDER BY il.DepartureDate, b.RecordLocator;