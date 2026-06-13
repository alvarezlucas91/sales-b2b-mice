SELECT
  PaxNoShow_GBPTG.IATA,
  PaxNoShow_GBPTG.REC_LOC,
  PaxNoShow_GBPTG.AIRPORT_ORIG,
  PaxNoShow_GBPTG.AIRPORT_DEST,
  PaxNoShow_GBPTG.FLIGHT_NUMBER,
  PaxNoShow_GBPTG.FLIGHT_DATE,
  PaxNoShow_GBPTG.FLIGHT_MONTH,
  PaxNoShow_GBPTG.AGENCYNAME,
  PaxNoShow_GBPTG.PAX_TOTAL,
  PaxNoShow_GBPTG.NS_TOTAL,
  PaxNoShow_GBPTG.ADT_TOTAL,
  PaxNoShow_GBPTG.CHD_TOTAL
FROM
  (
  select
	FP.IATA,
	FS.REC_LOC,
	FF.AIRPORT_ORIG,
	FF.AIRPORT_DEST,
	FF.FLIGHT_NUMBER,
	CAST(FF.FLIGHT_DATE AS DATE) AS FLIGHT_DATE,
	MONTH(FF.FLIGHT_DATE) AS FLIGHT_MONTH,
	dc.channel_lvl7 AS AGENCYNAME,
	COUNT(*) AS PAX_TOTAL,
	SUM(CASE WHEN FS.LIFT_STATUS = 'NS' THEN 1 ELSE 0 END) AS NS_TOTAL,
	sum(case when fs.type_code in ('ADT','RESA') then 1 else 0 end) as ADT_TOTAL,
	sum(case when fs.type_code in ('CHD','RESC') then 1 else 0 end) as CHD_TOTAL
from
	dbo.FactPNR fp
		inner join dbo.FactSegment fs on fp.rec_loc = fs.rec_loc
		inner join dbo.FactFlight ff on fs.flight_sk = ff.flight_sk
		left join dbo.factsegment_ventaschannel fsvc on fsvc.rec_loc = fs.rec_loc
		left join Vueling_Ventas.dbo.dimchannel dc on dc.id_channel = fsvc.id_channel
where
	1 = 1
	and CONVERT(nvarchar,ff.flight_date,112) between '{0}' and '{1}'
	and fp.sales_sk = 1 and ff.idstatus<>4
	and fs.fare_basis_nav = 'GBPTG'
	and fs.lift_status = 'NS'
group by
	fp.iata,
	fs.rec_loc,
	ff.airport_orig,
	ff.airport_dest,
	ff.flight_number,
	cast(ff.flight_date as date),
	month(ff.flight_date),
	 dc.channel_lvl7)  PaxNoShow_GBPTG;