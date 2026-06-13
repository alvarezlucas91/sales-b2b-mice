SELECT
  dimDate_Flight.date as Flight_Date,
  vueling_calcods.dbo.FactFlight.flight_number as Flight_Number,
  Vueling_data_master.dbo.dimAirport.airport as Airport_Orig,
  dimAirportDest.airport as Airport_Dest,
  vueling_calcods.dbo.FactPNR.rec_loc as PNR,
  vueling_calcods.dbo.FactPNR.iata as Agency,
  Vueling_data_master.dbo.DIM_AGENCY.AT_GROUP as Agency_Name,
  vueling_calcods.dbo.FactFlight.seats as Capacidad,
  sum(vueling_calcods.dbo.factSegment.tax_2) as Importe_Tasa,
  Vueling_ODS.dbo.PNR_PAX.PAX_NBR as Pax_NS

FROM
  vueling_calcods.dbo.factSegment INNER JOIN vueling_calcods.dbo.factSegment  DimSegment
    ON (vueling_calcods.dbo.factSegment.coupon_sk=DimSegment.coupon_sk)
  INNER JOIN vueling_calcods.dbo.FactPNR
    ON (vueling_calcods.dbo.FactPNR.rec_loc=DimSegment.rec_loc)
  INNER JOIN vueling_calcods.dbo.dimsalesstatus
    ON (vueling_calcods.dbo.dimsalesstatus.sales_sk=vueling_calcods.dbo.FactPNR.sales_sk)
  RIGHT OUTER JOIN Vueling_data_master.dbo.DIM_AGENCY
    ON (vueling_calcods.dbo.FactPNR.booking_date between Vueling_data_master.dbo.DIM_AGENCY.AT_DT_VALID_FROM and Vueling_data_master.dbo.DIM_AGENCY.AT_DT_VALID_TO and Vueling_data_master.dbo.DIM_AGENCY.AT_CD_IATA=vueling_calcods.dbo.FactPNR.iata)
  INNER JOIN vueling_calcods.dbo.FactFlight
    ON (DimSegment.flight_sk=vueling_calcods.dbo.FactFlight.flight_sk)
  INNER JOIN Vueling_data_master.dbo.dimAirport  dimAirportDest
    ON (dimAirportDest.airport=vueling_calcods.dbo.FactFlight.airport_dest)
  INNER JOIN Vueling_data_master.dbo.dimAirport
    ON (Vueling_data_master.dbo.dimAirport.airport=vueling_calcods.dbo.FactFlight.airport_orig)
  INNER JOIN Vueling_data_master.dbo.dimDate  dimDate_Flight
    ON (dimDate_Flight.date=vueling_calcods.dbo.FactFlight.flight_date)
  INNER JOIN Vueling_ODS.dbo.PNR_PAX
    ON (DimSegment.rec_loc=Vueling_ODS.dbo.PNR_PAX.rec_loc and DimSegment.pax_nbr=Vueling_ODS.dbo.PNR_PAX.PAX_NBR)
  INNER JOIN Vueling_data_master.dbo.DIM_FARE
    ON (Vueling_data_master.dbo.DIM_FARE.ID_FARE=DimSegment.ID_FARE)

WHERE
( vueling_calcods.dbo.dimsalesstatus.sales_sk not in (3) and vueling_calcods.dbo.FactFlight.airline_code=vueling_calcods.dbo.FactFlight.mktCarrierCode  )
  AND
  (
    DimSegment.lift_status  IN  ( 'NS'  )
    AND
    Vueling_data_master.dbo.DIM_FARE.AT_CD_FARE_BASIS  IN  ( 'GCHARTER'  )
    AND
    vueling_calcods.dbo.dimsalesstatus.description  IN  ( 'Pagado'  )
    AND
    dimDate_Flight.yearmon_str  >=  '201904'
  )

GROUP BY
  dimDate_Flight.date,
  vueling_calcods.dbo.FactFlight.flight_number,
  Vueling_data_master.dbo.dimAirport.airport,
  dimAirportDest.airport,
  vueling_calcods.dbo.FactPNR.rec_loc,
  vueling_calcods.dbo.FactPNR.iata,
  Vueling_data_master.dbo.DIM_AGENCY.AT_GROUP,
  vueling_calcods.dbo.FactFlight.seats,
  Vueling_ODS.dbo.PNR_PAX.PAX_NBR;