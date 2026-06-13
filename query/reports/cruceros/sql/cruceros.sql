select
	FF.flight_number as Flight_Number,
	cast(FF.flight_date as date) as Flight_date,
	left(cast(FF.STDUTC as time), 5) as Hora_Salida,
	left(cast(FF.STAUTC as time), 5) as Hora_Llegada,
	FF.airport_orig as Airport_Orig,
	FF.airport_dest as Airport_Dest,
	count(1) as Total_pax,
	(case when FF.route in ('VCEBCN','BCNBER','BCNMAN','BCNBRU','BCNMUC','HAMBCN','BCNLGW','FCOBCN','CPHBCN','FCOLGW','ATHBCN','CTABCN','BRIBCN') then 'Inbound Cruise'
		when FF.route in ('BCNVCE','BERBCN','MANBCN','BRUBCN','BCNHAM','LGWBCN','MUCBCN','BCNFCO','BCNCPH','LGWFCO','BCNATH','BCNCTA','BCNBRI') then 'Outbound Cruise'
		else 'Unknown'
	end) as Coment_Flight,
	sum(case when FP.iata = '38254731' and FS.fare_basis_nav = 'GBPTG' then 1 else 0 end) as MSC,
	sum(case when FP.iata = '38203303' and FS.fare_basis_nav = 'GBPTG' then 1 else 0 end) as COSTA,
	sum(case when FP.iata = '91223123' and FS.fare_basis_nav = 'GBPTG' then 1 else 0 end) as RCL,
	sum(case when FP.iata in ('23252073') and FS.fare_basis_nav = 'GBPTG' then 1 else 0 end) as AIDA
	from VUELING_CALCODS.dbo.FactSegment FS
		inner join VUELING_CALCODS.dbo.FactFlight FF on FF.flight_sk = FS.flight_sk
		inner join VUELING_CALCODS.dbo.FactPnr FP on FP.rec_loc = FS.rec_loc
		inner join  Vueling_data_master.dbo.DIM_ROUTE dr
		on dr.AT_CD_ORIG = ff.airport_orig and dr.AT_CD_DEST = ff.airport_dest
  where
	FP.iata in ('38254731', '38203303', '91223123', '23252073')
	and FS.fare_basis_nav in ('GBPTG')
	and FF.flight_date BETWEEN  CAST(GETDATE()AS DATE) AND  CAST(DATEADD(WK,2,GETDATE())AS DATE)
group by
	FF.flight_number,
	FF.flight_date,
	FF.STDUTC,
	FF.STAUTC,
	FF.airport_orig,
	FF.airport_dest,
	FF.route
order by 2