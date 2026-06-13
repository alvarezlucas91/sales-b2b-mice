SELECT
  dimDate_Flight.AT_CD_YEAR_MONTH as yearmon_str,
  sum(fs.discount+fs.tax_1+fs.tax_2+fs.tax_3+fs.tax_6) AS ACTUAL_TICKET_REVENUE
FROM
  vueling_calcods.dbo.factSegment fs INNER JOIN vueling_calcods.dbo.factSegment  DimSegment ON (fs.coupon_sk=DimSegment.coupon_sk)
   INNER JOIN vueling_calcods.dbo.FactPNR fp ON (fp.rec_loc=DimSegment.rec_loc)
   INNER JOIN vueling_calcods.dbo.dimsalesstatus dss ON (dss.sales_sk=fp.sales_sk)
   INNER JOIN vueling_calcods.dbo.DimChannelPhysical dcp ON (dcp.id_channel_physical=fp.id_PhysicalChannel)
   INNER JOIN vueling_data_master.dbo.dim_Date  dimDate_Booking ON (fp.booking_date=dimDate_Booking.AT_CD_AN_DATE)
   INNER JOIN vueling_calcods.dbo.FactFlight ff ON (DimSegment.flight_sk=ff.flight_sk)
   INNER JOIN vueling_data_master.dbo.dim_Date  dimDate_Flight ON (dimDate_Flight.AT_CD_AN_DATE=ff.flight_date)
   INNER JOIN vueling_data_MASTER.dbo.DIM_FARE df ON (df.ID_FARE=DimSegment.ID_FARE)

  WHERE
( ff.idStatus=1  )
  AND  ( dss.sales_sk not in (3) and ff.airline_code=ff.mktCarrierCode  )
  AND
  (
   dcp.channel_lvl2  IN  ( 'VY.COM','MOBIL','VY.COM MyVueling','MOBIL APP','VY.COM Anonimous'  )
   AND
   df.AT_CD_FARE_BASIS  NOT IN  ( 'ASSTBY0'  )
   AND
   df.AT_FAMILY_FARE   NOT IN  ( 'ZED High','ZED Medium','ZED LOW'  )
   AND
   fp.currency  <>  'EUR'
   AND
   dimDate_Flight.AT_CD_YEAR  IN  ( year(getdate()) )
  AND  (ff.idStatus=1)
   AND
   dimDate_Booking.AT_CD_YEAR_MONTH  >=  '201904'
   AND
   isnull(ff.mktCarrierCode,'VY')  IN  ( 'vy'  )
   AND
   dss.description  NOT IN  ( 'Cancelado','Hold'  )
  )
GROUP BY
  dimDate_Flight.AT_CD_YEAR_MONTH
