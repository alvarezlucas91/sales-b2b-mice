
SELECT
	TbaSAS.pnr,
	TbaSAS.numvuelo,
	TbaSAS.org,
	TbaSAS.dst,
	TbaSAS.status,
	TbaSAS.pax,
	TbaSAS.fecha,
	TbaSAS.farebasis,
	TbaSAS.iata,
	TbaSAS.des_iata
FROM  (select distinct
			c.*,
			case when sales_sk = 1 then 'Aceptada'
				when sales_sk = 2 then 'Pendiente'
				when sales_sk = 3 then 'Cancelada' else 'Hold'
			end as EstadoReserva,
			case when idstatus = 1 then 'Activo' else 'Cancelado' end as EstadoVuelo,
			i.AT_NAME as des_iata,
			case when fp.pnr_total <> total_payments then 'Pendiente' else '' end as estado,
			CommentText as Comentarios, fe.seat
		from (select
			case when tba = 1 then
				case when sum_pax = pax then 'TBA' else 'Algun TBA' end
				else 'No'
			end as is_tba,
			pnr,
			numvuelo,
			org,
			dst,
			[status],
			pax,
			fecha,
			tarifa,
			farebasis,
			freserva,
			iata
			from (select
				max(tba) as tba,
				max(sum_pax) as sum_pax,
				pnr,
				numvuelo,
				org,
				dst,
				[status],
				pax,
				fecha,
				tarifa,
				farebasis,
				freserva,
				iata
				from (select
						s.rec_loc as pnr,
						f.flight_number as numvuelo, airport_orig as org, airport_dest as dst, dss.description as status,p.nbr_of_pax as pax, cast(flight_date as date) as fecha,s.cdiscount + s.reparto_fees as tarifa, s.fare_basis_nav as farebasis, p.booking_date as freserva, p.arc_iata as iata, count(*) as sum_pax,case when pp.first_name like '%TBA%' then 1 else 0 end as tba
from dbo.factPnr p
JOIN dbo.dimsalesstatus dss on dss.sales_sk = p.sales_sk
join dbo.factSEgment s on p.rec_loc=s.rec_loc
join dbo.factFlight f on s.flight_sk=f.flight_sk
join vueling_ods.dbo.pnr_pax pp on s.rec_loc=pp.rec_loc and s.pax_nbr=pp.pax_nbr
where 1 =1
			and flight_date between cast(getdate() as date)
			and DATEADD(dd, 60, cast(getdate() as date))
			and left(fare_basis_nav, 1) = 'G'
			and p.sales_sk = 2
			and p.sales_sk<>3group by s.rec_loc, flight_number, airport_orig, airport_dest,  dss.description, nbr_of_pax, cast(flight_date as date), s.cdiscount + s.reparto_fees, fare_basis_nav, p.booking_date,case when first_name like '%TBA%' then 1 else 0 end, arc_iata
            ) b
            group by pnr, numvuelo, org, dst, [status], pax, fecha, tarifa, farebasis, freserva, iata
        ) d
) c
inner join dbo.factpnr fp on fp.rec_loc = c.pnr
left join dbo.factflight ff on cast(ff.flight_date as date) = c.fecha and ff.flight_number = c.numvuelo and idstatus = 1inner join vueling_navitaire.[dbo].[Booking] b WITH(NOLOCK) on b.recordlocator = c.pnr
left join vueling_navitaire.[dbo].[BookingComment] bc WITH(NOLOCK) on bc.bookingid = b.bookingid
left join (select distinct AT_CD_IATA, AT_NAME from Vueling_data_master.DBO.DIM_AGENCY where AT_DT_VALID_TO = '9999-12-31 00:00:00.000') i on i.AT_CD_IATA = c.iata
left join (select AT_CD_PNR as pnr, count(distinct f.AT_CD_PAX_NBR) as seat, ID_FLIGHT
from fees.fact_fee f join Vueling_data_master.dbo.DIM_FEE_TYPE t on f.ID_FEE_TYPE=t.ID_FEE_TYPE
where ot_dt_end_date='29991231'and t.AT_CD_SERVICE_TYPE='SEAT'group by AT_CD_PNR,ID_FLIGHT) fe on fp.rec_loc=fe.pnr and fe.id_flight=ff.flight_sk
  )  TbaSAS
WHERE
	TbaSAS.tarifa <> 0
	AND (TbaSAS.farebasis = 'GBPTG' OR TbaSAS.farebasis = 'GCHARTER')
	AND cast(fecha as date) between '{0}' and '{1}';