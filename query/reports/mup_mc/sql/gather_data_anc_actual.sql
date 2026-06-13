SELECT
  dimDate_Flight.yearmon_str,
  SUM(v.MT_NAVITAIRE_TOTAL_COST_AMOUNT) AS ACTUAL_REVENUE_GROSS
FROM
  VUELING_CALCODS.dbo.FactFlight ff
	RIGHT OUTER JOIN vueling_calcods.fees.V_FACT_FEE_ACTIVE v ON (ff.flight_sk=v.ID_FLIGHT)
   INNER JOIN vueling_calcods.dbo.FactPNR fp ON (fp.rec_loc=v.AT_CD_PNR)
   INNER JOIN vueling_calcods.dbo.dimsalesstatus dss ON (dss.sales_sk=fp.sales_sk)
   LEFT OUTER JOIN vueling_data_master.dbo.DIM_FARE df ON (df.ID_FARE=v.ID_FARE)
   LEFT OUTER JOIN vueling_data_master.dbo.DIM_AGENT da ON (da.ID_AGENT=v.ID_AGENT)
   LEFT OUTER JOIN vueling_data_master.dbo.dimDate  dimDate_Flight ON (dimDate_Flight.date=v.AT_DT_FLIGHT)
   INNER JOIN vueling_calcods.dbo.dimDate  dimDate_sales ON (dimDate_sales.date=v.AT_DT_BOOKING)

WHERE
( ff.idStatus=1  )
  AND
  (
   isnull(ff.mktCarrierCode,'VY')  IN  ( 'vy'  )
   AND
   df.AT_CD_FARE_BASIS  NOT IN  ( 'ASSTBY0'  )
   AND
   df.AT_FAMILY_FARE   NOT IN  ( 'ZED High','ZED Medium','ZED LOW'  )
   AND
   fp.currency  <>  'EUR'
   AND
   dimDate_Flight.year  IN  ( year(getdate())  )
  AND  (ff.idStatus=1)
   AND
   da.AT_DEPARTMENT_NAME  IN  ( 'Web Location','Mobile'  )
   AND
   dimDate_sales.yearmon_str  >=  '201904'
   AND
   dss.description  NOT IN  ( 'Cancelado','Hold'  )
  )
GROUP BY
  dimDate_Flight.yearmon_str
