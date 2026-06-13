SELECT
  DMV.dbo.TA_rec_loc_otros1.rec_loc AS "Rec Loc",
  dimDate_Booking.date_str AS "Booking Date",
  count(dbo.factSegment.coupon_sk) AS "Actual number"
FROM
  dbo.FactFlight INNER JOIN dbo.factSegment  DimSegment ON (DimSegment.flight_sk=dbo.FactFlight.flight_sk)
   INNER JOIN dbo.FactPNR ON (dbo.FactPNR.rec_loc=DimSegment.rec_loc)
   INNER JOIN dbo.dimsalesstatus ON (dbo.dimsalesstatus.sales_sk=dbo.FactPNR.sales_sk)
   INNER JOIN DMV.dbo.TA_rec_loc_otros1 ON (DMV.dbo.TA_rec_loc_otros1.rec_loc=dbo.FactPNR.rec_loc)
   INNER JOIN DMV_Vueling_ventas.dbo.dimDate  dimDate_Booking ON (dbo.FactPNR.booking_date=dimDate_Booking.date)
   INNER JOIN dbo.factSegment ON (dbo.factSegment.coupon_sk=DimSegment.coupon_sk)
WHERE
( dbo.dimsalesstatus.sales_sk not in (3)   )
  AND  
  dbo.FactFlight.airline_code  IN  ( 'VY'  )
  AND  (dbo.FactFlight.idStatus=1)
GROUP BY
  DMV.dbo.TA_rec_loc_otros1.rec_loc, 
  dimDate_Booking.date_str
ORDER BY DMV.dbo.TA_rec_loc_otros1.rec_loc