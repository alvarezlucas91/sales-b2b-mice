-- Hoja Canales

SELECT
  ContactosIndirectos.rec_loc as [PNR],
  ContactosIndirectos."Año" as [Year],
  ContactosIndirectos.Mes,
  ContactosIndirectos.Channel,
  ContactosIndirectos.Iscontact,
  ContactosIndirectos.IsNotcontact
FROM
  (
  SELECT distinct B.REC_LOC,
			        YEAR(B.booking_date) AS [Año],
					MONTH(B.booking_date) AS [Mes],
					( CASE WHEN channel_lvl1 = 'GDS' then 'GDS'
			               WHEN channel_lvl2 IN ('B2B','B2B Agency','B2B Corporate') then 'Web Agencias'
                     ELSE channel_lvl2
					 END ) as Channel,
					B.IATA,
					DA.AT_GROUP AS GROUP_AGENCY,
					DA.AT_NAME AS AGENCIA,
					EM.EmailAgency,
					( CASE WHEN EP.EmailPas IS NOT NULL OR (EM.EmailAgency IS NOT NULL OR EM.EmailAgency <> '') OR (EG.EmailAgency IS NOT NULL OR EG.EmailAgency <> '') THEN 1 ELSE 0 end) as Iscontact,
					( CASE WHEN EP.EmailPas IS NULL AND (EM.EmailAgency IS NULL OR EM.EmailAgency='') AND (EG.EmailAgency IS NULL OR EG.EmailAgency='') THEN 1 ELSE 0 end) as IsNotcontact
         FROM  VUELING_CALCODS.dbo.FACTPNR B
			   JOIN VUELING_CALCODS.dbo.DimChannelPhysical DC
				  ON B.id_PhysicalChannel =dc.id_channel_physical
				JOIN VUELING_NAVITAIRE.ODS_DATABASE.BookingContact BC
					ON B.BookingID = BC.BookingID
				LEFT JOIN ( SELECT P.BookingID,P.PassengerID,EmailAddress AS EmailPas
			                FROM    VUELING_NAVITAIRE.dbo.BOOKINGPASSENGER P WITH(NOLOCK)
						    JOIN  VUELING_NAVITAIRE.ODS_DATABASE.PassengerAddress PA with(nolock)
                            ON P.PassengerID= PA.PassengerID
						    WHERE EmailAddress <>'' and typecode = 'C')EP
					ON  B.BookingID = EP.BookingID
                 LEFT JOIN VUELING_DATA_MASTER.DBO.DIM_AGENCY DA
					ON B.IATA = AT_CD_IATA AND DA.AT_DT_VALID_TO ='9999-12-31'
               LEFT JOIN ( SELECT DISTINCT BOOKINGID,EmailAddress  as EmailAgency FROM VUELING_NAVITAIRE.ODS_DATABASE.BookingContact E
			               WHERE    TypeCode  IN ('A','I') and SourceOrganization<>'') EM
				ON B.BOOKINGID = EM.BookingID
               LEFT JOIN ( SELECT DISTINCT BOOKINGID,EmailAddress  as EmailAgency FROM VUELING_NAVITAIRE.ODS_DATABASE.BookingContact E
			               WHERE    TypeCode = 'G') EG
				ON B.BOOKINGID = EG.BookingID and EG.BookingID  = EM.BookingID
			WHERE BC.TYPECODE ='G'
			AND SALES_SK =1
			AND B.booking_date between '{0}' and '{1}'
			AND EXISTS (select 1 from VUELING_NAVITAIRE.dbo.PassengerJourneySSR SSR WITH(NOLOCK)
			             JOIN VUELING_NAVITAIRE.dbo.BOOKINGPASSENGER BP WITH(NOLOCK)
			            ON SSR.PassengerID= BP.PassengerID
						WHERE B.BookingID = BP.BookingID )

  )  ContactosIndirectos