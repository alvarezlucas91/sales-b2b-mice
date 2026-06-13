SELECT
  DDB.date_str as [Booking Date],
  FF.flight_number as [Flight Number],
  DR.AT_CD_ORIG as [Origin],
  DR.AT_CD_DEST as [Destination],
  DDF.[date]  as [Flight date],
  FPE.email_equiv as [Contact e-mail],
  LOC.FIRST_NAME as [Contact information First name],
  LOC.LAST_NAME as [Contact information Last name],
  DCP.channel_lvl3 as [Integrator],
  DC.channel_lvl8 as [B2B client],
  sum(FAT.mt_company_base_amount)  as [Company base amount],
  FP.rec_loc as [PNR]

FROM
   VUELING_CALCODS.dbo.dimsalesstatus DSS
   INNER JOIN VUELING_CALCODS.dbo.FEES_AND_TICKET FAT
   ON (DSS.sales_sk = FAT.id_status)
   INNER JOIN VUELING_CALCODS.dbo.FactPNR FP
   ON (FP.rec_loc = FAT.AT_CD_PNR)
   INNER JOIN VUELING_CALCODS.dbo.factSegment_VentasChannel FVC
   ON (FVC.rec_loc = FP.rec_loc)
   INNER JOIN Vueling_Ventas.dbo.DimChannel DC
   ON (FVC.id_channel = DC.id_channel)
   INNER JOIN VUELING_CALCODS.dbo.DimChannelPhysical DCP
   ON (DCP.id_channel_physical = FP.id_PhysicalChannel)
   LEFT OUTER JOIN VUELING_CALCODS.dbo.factPnrEmail FPE
   ON (FPE.rec_loc = FP.rec_loc)
   LEFT OUTER JOIN Vueling_CALCODS.dbo.PNR_PAX LOC
   ON (LOC.REC_LOC = FPE.REC_LOC)
   INNER JOIN VUELING_CALCODS.dbo.dimDate  DDB
   ON (FP.booking_date = DDB.date)
   LEFT OUTER JOIN VUELING_CALCODS.dbo.FactFlight FF
   ON (FF.flight_sk = FAT.ID_FLIGHT)
   INNER JOIN Vueling_data_master.dbo.DIM_ROUTE DR
   ON (FF.airport_orig = DR.AT_CD_ORIG and FF.airport_dest = DR.AT_CD_DEST)
   INNER JOIN VUELING_CALCODS.dbo.dimDate  DDF
   ON (DDF.[date] = FF.flight_date)

WHERE ( 1=1  )
  AND
  (
   DCP.channel_lvl3  LIKE  '%Ypsilon%'
   AND
   DDB.date_str  =  convert(varchar(8), getdate()-1, 112)
   AND
   DSS.description  IN  ( 'Pagado'  )
  )
GROUP BY
  DDB.date_str,
  FP.rec_loc,
  FF.flight_number,
  LOC.FIRST_NAME,
  LOC.LAST_NAME,
  DCP.channel_lvl3,
  FPE.email_equiv,
  DC.channel_lvl8,
  DDF.[date],
  DR.AT_CD_ORIG,
  DR.AT_CD_DEST

order by
	flight_number