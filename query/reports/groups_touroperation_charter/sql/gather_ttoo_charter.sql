SELECT
  Tarifas_GBPTG_GCHARTER.flight_number,
  Tarifas_GBPTG_GCHARTER.airline_code,
  Tarifas_GBPTG_GCHARTER.flight_date,
  Tarifas_GBPTG_GCHARTER.HoraSalida,
  Tarifas_GBPTG_GCHARTER.HoraLlegada,
  Tarifas_GBPTG_GCHARTER.airport_orig,
  Tarifas_GBPTG_GCHARTER.airport_dest,
  Tarifas_GBPTG_GCHARTER.pnrs,
  --Tarifas_GBPTG_GCHARTER.booking_date,
  Tarifas_GBPTG_GCHARTER.iata,
  Tarifas_GBPTG_GCHARTER.nombre_comercial,
  Tarifas_GBPTG_GCHARTER.tarifa,
  Tarifas_GBPTG_GCHARTER.totalPax,
  Tarifas_GBPTG_GCHARTER.paxiata,
  Tarifas_GBPTG_GCHARTER.seats,
  Tarifas_GBPTG_GCHARTER.asientosReservados,
  Tarifas_GBPTG_GCHARTER.CosteTotal,
  Tarifas_GBPTG_GCHARTER.lf
FROM
  (
  SELECT  DISTINCT
	stg.flight_number,
	tp.airline_code,
	cast(stg.flight_date as DATE) as flight_date,
	stg.HoraSalida,
	stg.HoraLlegada,
	stg.airport_orig,
	stg.airport_dest,
	stg.pnrs,
	--tp.booking_date,
	stg.iata,
	stg.nombre_comercial,
	tp.totalPax as totalPax,
	stg.pax as paxiata,
	cast(stg.seats as int) as seats,
	stg.asientosReservados,
	stg.pnr_total as CosteTotal,
	(100*cast(tp.totalPax as numeric(18,2))/stg.seats) as lf
	,tp.fare_basis_nav as tarifa
	FROM
	vueling_calcods.ttoo.STG_FLIGHT_PNRS stg
	join
		(
			select ff.flight_sk,ff.airline_code,count(*) as totalPax, fs.fare_basis_nav--, CAST(fs.booking_date as date) as booking_date
			from vueling_calcods..FACTFLIGHT FF
			join vueling_calcods..FACTSEGMENT FS ON FF.flight_sk = FS.flight_sk
			group by ff.flight_sk,ff.airline_code, fs.fare_basis_nav--, CAST(fs.booking_date as date)
		) tp on tp.flight_sk=stg.flight_sk
	where tp.fare_basis_nav in ('GBPTG', 'GCHARTER') --and stg.pnrs =('sd9n5c')
  )  Tarifas_GBPTG_GCHARTER

