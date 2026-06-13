SELECT
  SSR_TTOO.iata,
  SSR_TTOO.rec_loc,
  SSR_TTOO.airport_orig,
  SSR_TTOO.airport_dest,
  SSR_TTOO.flight_number,
  SSR_TTOO.flight_date,
  SSR_TTOO.fl_month,
  SSR_TTOO.AgencyName,
  SSR_TTOO.SSRCount,
  SSR_TTOO.SSRFee,
  SSR_TTOO.SSRName
FROM
  (
  select p.rec_loc, p.iata, f.airport_orig, f.airport_dest, f.flight_number, f.flight_date, convert(varchar(6), f.flight_Date,112) as fl_month
,m.grupo as AgencyName
,sum(case when sr.rec_loc is not null then 1 else 0 end) as SSRCount,
sum(case when Anc.rec_loc is not null then service_base_amount else 0 end) as SSRFee,
SSRName
FROM  dbo.factPnr p join dbo.factSegment s on p.rec_loc=s.rec_loc
left join ( select ff.AT_CD_PNR as rec_loc, ff.AT_CD_SEG_SEQ_NBR as SEG_SEQ_NBR,AT_CD_SERVICE_TYPE AS SSRCODE,AT_DS_REVENUE_CONCEPT_3 as SSRName,
                  ff.AT_CD_PAX_NBR as PAX_NBR, MT_COMPANY_BASE_AMOUNT  as service_base_amount
            from fees.fact_fee ff join Vueling_data_master.dbo.DIM_FEE_TYPE t on ff.ID_FEE_TYPE=t.ID_FEE_TYPE
            where at_cd_service_type NOT IN  ('IF','CXINF') and OT_DT_END_DATE='29991231') Anc
			ON Anc.rec_loc = p.rec_loc and Anc.seg_seq_nbr = s.seg_seq_nbr and Anc.pax_nbr = s.pax_nbr
join dbo.FactFlight f on s.flight_sk=f.flight_sk
join vueling_ods.dbo.segment_ssr sr on s.rec_loc=sr.rec_loc and s.pax_nbr=sr.pax_nbr and s.seg_Seq_nbr=sr.seg_seq_nbr
	 and sr.ssr_code = Anc.SSRCODE
join dbo.dimchannel c on p.id_channel=c.id_channel
left join (select AT_CD_IATA AS id_iata, max(AT_GROUP) as grupo from Vueling_data_master.dbo.DIM_AGENCY where cast(AT_DT_VALID_TO as date)='9999-12-31' group by AT_CD_IATA) m
ON  m.id_iata = p.iata
where
flight_date between '{0}' and '{1}' and
channel_lvl2 in  ('VY TTOO CUPOS', 'VY TTOO IND')
and fare_basis_nav  = 'GBPTG'
and  exists (select 1 from vueling_ods.dbo.pnr_payment t where p.rec_loc = t.rec_loc and t.type_code='TR')
and  not exists (select 1 from vueling_ods.dbo.pnr_payment t where p.rec_loc = t.rec_loc and t.type_code<>'TR')
group by p.rec_loc, p.iata, f.airport_orig, f.airport_dest, f.flight_number, f.flight_date,m.grupo,SSRName

  )  SSR_TTOO
WHERE
  SSR_TTOO.SSRFee  <>  0
