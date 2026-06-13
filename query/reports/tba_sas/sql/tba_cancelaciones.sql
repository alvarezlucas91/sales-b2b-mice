SELECT
		TbaSASCancelaciones.pnr,
		TbaSASCancelaciones.org,
		TbaSASCancelaciones.dst,
		TbaSASCancelaciones.numvuelo,
		TbaSASCancelaciones.status,
		TbaSASCancelaciones.farebasis,
		TbaSASCancelaciones.pax,
		TbaSASCancelaciones.fecha,
		TbaSASCancelaciones.freserva,
		TbaSASCancelaciones.tarifa
FROM
	(
	select pnr,
			org,
			dst,
			numvuelo,
			[status],
			farebasis,
			pax,
			fecha,
			freserva,
			sum(tarifa) as tarifa
	from
		(
		select p.rec_loc as pnr,
				f.airport_orig as org,
				f.airport_dest as dst,
				flight_number as numvuelo,
				dss.description as [status],
				fare_basis_nav as farebasis,
				nbr_of_pax as pax,
				flight_date as fecha,
				case
					when left(fare_basis_nav, 1) <> 'A' and base_fare < 1.0 then base_fare*100+tax_4
					else base_fare+tax_4
				end as tarifa,
				p.booking_date as freserva
		from factPnr p
			JOIN dimsalesstatus dss
				on dss.sales_sk = p.sales_sk
			join factSEgment s
				on p.rec_loc=s.rec_loc
			join factFlight f
				on s.flight_sk=f.flight_sk
		where flight_date between cast(getdate() as date) and DATEADD(dd, 60, cast(getdate() as date))
				and fare_basis_nav in ('GBPTG', 'GCHARTER') and p.sales_sk = 3
		) a
	group by pnr,
			org,
			dst,
			numvuelo,
			[status],
			farebasis,
			pax,
			fecha,
			freserva
	) TbaSASCancelaciones
ORDER BY TbaSASCancelaciones.pnr
