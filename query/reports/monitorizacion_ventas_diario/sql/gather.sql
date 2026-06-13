SELECT C1.DAY, C1.HORA, C1.channel_lvl1, C1.channelLvl2, C1.DATOS

FROM (

SELECT
  'TODAY' as DAY,
  Sales_hour_physical_channel.BD,
  Sales_hour_physical_channel.channel_lvl1,
  Sales_hour_physical_channel.channelLvl2,
  sum(Sales_hour_physical_channel.bookings) DATOS,
  Sales_hour_physical_channel.Expr1,
  left(Sales_hour_physical_channel.Expr1,2) HORA
FROM
  (
  select *
from (

	select
	CONVERT(nvarchar(8), DATEADD(minute,TimeZoneVariation.Variation,i.BookingUTC),112) as BD,
	RIGHT('00'+CAST (DATEPART(hour,DATEADD(minute,TimeZoneVariation.Variation,i.BookingUTC)) AS VARCHAR(2)),2)+':'+
		substring(convert(nvarchar,dateadd(MINUTE,substring(convert(varchar,CONVERT(time, i.BookingUTC)),5,1)%2,i.BookingUTC),120),15,2) as  hour,

	---------------- CHANNEL_LVL1 --------------------
	case when i.ChannelType = 1 then 'DIRECT'
		when i.ChannelType = 2 then 'WEB'
		when i.ChannelType = 3 then 'GDS'
		when i.ChannelType = 4 then 'API'
		else 'OTROS' end as channel_lvl1,
	---------------- CHANNEL_LVL2 --------------------
	case when i.ChannelType = 1 and l.locationType = 1 then 'AIRPORT'
		when i.ChannelType = 1 and l.locationType = 0 and a.DepartmentCode = 'CC' and l.LocationCode not in ('HDQ') then 'CC'
		when i.ChannelType = 1 and l.locationType = 0 and l.LocationCode in ('HDQ') then 'HDQ'
		when i.ChannelType = 1 and l.locationType = 0   then 'OTROS'

		when i.ChannelType = 2 and i.CreatedLocationCode in ('SYS','WWW') then 'VY.COM'
		when i.ChannelType = 2 and i.CreatedLocationCode in ('AGD','BSP','VLG','AGET ') then 'B2B'
		when i.ChannelType = 2 and i.CreatedLocationCode in ('LWEB') then 'FLYLEVEL.COM'
		when i.ChannelType = 2 then 'OTROS'

		when i.ChannelType = 3 and br.OwningSystemCode ='1A' then 'AMADEUS'
		when i.ChannelType = 3 and br.OwningSystemCode ='1G' then 'GALILEO'
		when i.ChannelType = 3 and br.OwningSystemCode ='1P' then 'WORLDSPAN'
		when i.ChannelType = 3 and br.OwningSystemCode ='IB' then 'CODEIB'
		when i.ChannelType = 3 and br.OwningSystemCode ='BA' then 'CODEBA'
		when i.ChannelType = 3 and br.OwningSystemCode ='1S' then 'SABRE'
		when i.ChannelType = 3 and br.OwningSystemCode ='1V' then 'APOLLO'
		when i.ChannelType = 3 and i.CreatedLocationCode = 'GDS' and br.OwningSystemCode = 'X3'  THEN 'TUIFLY'
		when i.ChannelType = 3 then 'OTROS'

		when i.ChannelType = 4 and i.CreatedUserCode ='APIG' OR i.CreatedUserCode like 'GR-%' then 'GROUPS'
		when i.ChannelType = 4 and i.CreatedUserCode ='TTOOAPI' then 'TTOO'
		when i.ChannelType = 4 and i.receivedBy like '%#VY#NDC'  then 'NDC'
		when i.ChannelType = 4 and i.CreatedUserCode like 'I3%' and i.CreatedUserCode not like  ('I3-mo2o%') then 'I3'
		when i.ChannelType = 4 and (i.CreatedUserCode like  ('I3-mo2o%') or i.CreatedUserCode in ('PortalWeb','AppIOS','AppW8','AppAndroid','AppBB','AppWP')) then 'MOBIL'
		when i.ChannelType = 4 and i.CreatedUserCode  = 'ApiIntra' then 'INTRANET'
		when i.ChannelType = 4 then 'OTROS'
		else 'NO APLICA'
	end as channelLvl2,
	count(*) as bookings
	from rez.booking i
		left join rez.location l on i.createdlocationcode = l.locationcode
		join rez.agent a on i.createdUserid=a.AgentID
		left join rez.BookingRecordLocator br on i.bookingId=br.bookingid
		inner join TimeZoneVariation on GETDATE() BETWEEN TimeZoneVariation.StartUTC AND TimeZoneVariation.EndUTC and  TimeZoneVariation.TimeZoneCode = 'ES1'
	where i.BookingUTC BETWEEN CONVERT(date, getDate()-1) AND CONVERT(date, DateAdd("d",1,getDate()))
		and  i.BookingUTC >= dateadd(MINUTE,TimeZoneVariation.Variation * -1,convert(nvarchar,GETDATE(),112))
	group by
	CONVERT(nvarchar(8), DATEADD(minute,TimeZoneVariation.Variation,i.BookingUTC),112),
	RIGHT('00'+CAST (DATEPART(hour,DATEADD(minute,TimeZoneVariation.Variation,i.BookingUTC)) AS VARCHAR(2)),2)+':'+
		substring(convert(nvarchar,dateadd(MINUTE,substring(convert(varchar,CONVERT(time, i.BookingUTC)),5,1)%2,i.BookingUTC),120),15,2),

	---------------- CHANNEL_LVL1 --------------------
	case when i.ChannelType = 1 then 'DIRECT'
		when i.ChannelType = 2 then 'WEB'
		when i.ChannelType = 3 then 'GDS'
		when i.ChannelType = 4 then 'API'
		else 'OTROS' end,
	---------------- CHANNEL_LVL2 --------------------
	case when i.ChannelType = 1 and l.locationType = 1 then 'AIRPORT'
		when i.ChannelType = 1 and l.locationType = 0 and a.DepartmentCode = 'CC' and l.LocationCode not in ('HDQ') then 'CC'
		when i.ChannelType = 1 and l.locationType = 0 and l.LocationCode in ('HDQ') then 'HDQ'
		when i.ChannelType = 1 and l.locationType = 0   then 'OTROS'

		when i.ChannelType = 2 and i.CreatedLocationCode in ('SYS','WWW') then 'VY.COM'
		when i.ChannelType = 2 and i.CreatedLocationCode in ('AGD','BSP','VLG','AGET ') then 'B2B'
		when i.ChannelType = 2 and i.CreatedLocationCode in ('LWEB') then 'FLYLEVEL.COM'
		when i.ChannelType = 2 then 'OTROS'

		when i.ChannelType = 3 and br.OwningSystemCode ='1A' then 'AMADEUS'
		when i.ChannelType = 3 and br.OwningSystemCode ='1G' then 'GALILEO'
		when i.ChannelType = 3 and br.OwningSystemCode ='1P' then 'WORLDSPAN'
		when i.ChannelType = 3 and br.OwningSystemCode ='IB' then 'CODEIB'
		when i.ChannelType = 3 and br.OwningSystemCode ='BA' then 'CODEBA'
		when i.ChannelType = 3 and br.OwningSystemCode ='1S' then 'SABRE'
		when i.ChannelType = 3 and br.OwningSystemCode ='1V' then 'APOLLO'
		when i.ChannelType = 3 and i.CreatedLocationCode = 'GDS' and br.OwningSystemCode = 'X3'  THEN 'TUIFLY'
		when i.ChannelType = 3 then 'OTROS'

		when i.ChannelType = 4 and i.CreatedUserCode ='APIG' OR i.CreatedUserCode like 'GR-%' then 'GROUPS'
		when i.ChannelType = 4 and i.CreatedUserCode ='TTOOAPI' then 'TTOO'
		when i.ChannelType = 4 and i.receivedBy like '%#VY#NDC'  then 'NDC'
		when i.ChannelType = 4 and i.CreatedUserCode like 'I3%' and i.CreatedUserCode not like  ('I3-mo2o%') then 'I3'
		when i.ChannelType = 4 and (i.CreatedUserCode like  ('I3-mo2o%') or i.CreatedUserCode in ('PortalWeb','AppIOS','AppW8','AppAndroid','AppBB','AppWP')) then 'MOBIL'
		when i.ChannelType = 4 and i.CreatedUserCode  = 'ApiIntra' then 'INTRANET'
		when i.ChannelType = 4 then 'OTROS'
		else 'NO APLICA'
	end
	) a
	right join
	(
	SELECT '00:00' as Expr1 UNION ALL
	SELECT '00:02' as Expr1 UNION ALL
	SELECT '00:04' as Expr1 UNION ALL
	SELECT '00:06' as Expr1 UNION ALL
	SELECT '00:08' as Expr1 UNION ALL
	SELECT '00:10' as Expr1 UNION ALL
	SELECT '00:12' as Expr1 UNION ALL
	SELECT '00:14' as Expr1 UNION ALL
	SELECT '00:16' as Expr1 UNION ALL
	SELECT '00:18' as Expr1 UNION ALL
	SELECT '00:20' as Expr1 UNION ALL
	SELECT '00:22' as Expr1 UNION ALL
	SELECT '00:24' as Expr1 UNION ALL
	SELECT '00:26' as Expr1 UNION ALL
	SELECT '00:28' as Expr1 UNION ALL
	SELECT '00:30' as Expr1 UNION ALL
	SELECT '00:32' as Expr1 UNION ALL
	SELECT '00:34' as Expr1 UNION ALL
	SELECT '00:36' as Expr1 UNION ALL
	SELECT '00:38' as Expr1 UNION ALL
	SELECT '00:40' as Expr1 UNION ALL
	SELECT '00:42' as Expr1 UNION ALL
	SELECT '00:44' as Expr1 UNION ALL
	SELECT '00:46' as Expr1 UNION ALL
	SELECT '00:48' as Expr1 UNION ALL
	SELECT '00:50' as Expr1 UNION ALL
	SELECT '00:52' as Expr1 UNION ALL
	SELECT '00:54' as Expr1 UNION ALL
	SELECT '00:56' as Expr1 UNION ALL
	SELECT '00:58' as Expr1 UNION ALL
	SELECT '01:00' as Expr1 UNION ALL
	SELECT '01:02' as Expr1 UNION ALL
	SELECT '01:04' as Expr1 UNION ALL
	SELECT '01:06' as Expr1 UNION ALL
	SELECT '01:08' as Expr1 UNION ALL
	SELECT '01:10' as Expr1 UNION ALL
	SELECT '01:12' as Expr1 UNION ALL
	SELECT '01:14' as Expr1 UNION ALL
	SELECT '01:16' as Expr1 UNION ALL
	SELECT '01:18' as Expr1 UNION ALL
	SELECT '01:20' as Expr1 UNION ALL
	SELECT '01:22' as Expr1 UNION ALL
	SELECT '01:24' as Expr1 UNION ALL
	SELECT '01:26' as Expr1 UNION ALL
	SELECT '01:28' as Expr1 UNION ALL
	SELECT '01:30' as Expr1 UNION ALL
	SELECT '01:32' as Expr1 UNION ALL
	SELECT '01:34' as Expr1 UNION ALL
	SELECT '01:36' as Expr1 UNION ALL
	SELECT '01:38' as Expr1 UNION ALL
	SELECT '01:40' as Expr1 UNION ALL
	SELECT '01:42' as Expr1 UNION ALL
	SELECT '01:44' as Expr1 UNION ALL
	SELECT '01:46' as Expr1 UNION ALL
	SELECT '01:48' as Expr1 UNION ALL
	SELECT '01:50' as Expr1 UNION ALL
	SELECT '01:52' as Expr1 UNION ALL
	SELECT '01:54' as Expr1 UNION ALL
	SELECT '01:56' as Expr1 UNION ALL
	SELECT '01:58' as Expr1 UNION ALL
	SELECT '02:00' as Expr1 UNION ALL
	SELECT '02:02' as Expr1 UNION ALL
	SELECT '02:04' as Expr1 UNION ALL
	SELECT '02:06' as Expr1 UNION ALL
	SELECT '02:08' as Expr1 UNION ALL
	SELECT '02:10' as Expr1 UNION ALL
	SELECT '02:12' as Expr1 UNION ALL
	SELECT '02:14' as Expr1 UNION ALL
	SELECT '02:16' as Expr1 UNION ALL
	SELECT '02:18' as Expr1 UNION ALL
	SELECT '02:20' as Expr1 UNION ALL
	SELECT '02:22' as Expr1 UNION ALL
	SELECT '02:24' as Expr1 UNION ALL
	SELECT '02:26' as Expr1 UNION ALL
	SELECT '02:28' as Expr1 UNION ALL
	SELECT '02:30' as Expr1 UNION ALL
	SELECT '02:32' as Expr1 UNION ALL
	SELECT '02:34' as Expr1 UNION ALL
	SELECT '02:36' as Expr1 UNION ALL
	SELECT '02:38' as Expr1 UNION ALL
	SELECT '02:40' as Expr1 UNION ALL
	SELECT '02:42' as Expr1 UNION ALL
	SELECT '02:44' as Expr1 UNION ALL
	SELECT '02:46' as Expr1 UNION ALL
	SELECT '02:48' as Expr1 UNION ALL
	SELECT '02:50' as Expr1 UNION ALL
	SELECT '02:52' as Expr1 UNION ALL
	SELECT '02:54' as Expr1 UNION ALL
	SELECT '02:56' as Expr1 UNION ALL
	SELECT '02:58' as Expr1 UNION ALL
	SELECT '03:00' as Expr1 UNION ALL
	SELECT '03:02' as Expr1 UNION ALL
	SELECT '03:04' as Expr1 UNION ALL
	SELECT '03:06' as Expr1 UNION ALL
	SELECT '03:08' as Expr1 UNION ALL
	SELECT '03:10' as Expr1 UNION ALL
	SELECT '03:12' as Expr1 UNION ALL
	SELECT '03:14' as Expr1 UNION ALL
	SELECT '03:16' as Expr1 UNION ALL
	SELECT '03:18' as Expr1 UNION ALL
	SELECT '03:20' as Expr1 UNION ALL
	SELECT '03:22' as Expr1 UNION ALL
	SELECT '03:24' as Expr1 UNION ALL
	SELECT '03:26' as Expr1 UNION ALL
	SELECT '03:28' as Expr1 UNION ALL
	SELECT '03:30' as Expr1 UNION ALL
	SELECT '03:32' as Expr1 UNION ALL
	SELECT '03:34' as Expr1 UNION ALL
	SELECT '03:36' as Expr1 UNION ALL
	SELECT '03:38' as Expr1 UNION ALL
	SELECT '03:40' as Expr1 UNION ALL
	SELECT '03:42' as Expr1 UNION ALL
	SELECT '03:44' as Expr1 UNION ALL
	SELECT '03:46' as Expr1 UNION ALL
	SELECT '03:48' as Expr1 UNION ALL
	SELECT '03:50' as Expr1 UNION ALL
	SELECT '03:52' as Expr1 UNION ALL
	SELECT '03:54' as Expr1 UNION ALL
	SELECT '03:56' as Expr1 UNION ALL
	SELECT '03:58' as Expr1 UNION ALL
	SELECT '04:00' as Expr1 UNION ALL
	SELECT '04:02' as Expr1 UNION ALL
	SELECT '04:04' as Expr1 UNION ALL
	SELECT '04:06' as Expr1 UNION ALL
	SELECT '04:08' as Expr1 UNION ALL
	SELECT '04:10' as Expr1 UNION ALL
	SELECT '04:12' as Expr1 UNION ALL
	SELECT '04:14' as Expr1 UNION ALL
	SELECT '04:16' as Expr1 UNION ALL
	SELECT '04:18' as Expr1 UNION ALL
	SELECT '04:20' as Expr1 UNION ALL
	SELECT '04:22' as Expr1 UNION ALL
	SELECT '04:24' as Expr1 UNION ALL
	SELECT '04:26' as Expr1 UNION ALL
	SELECT '04:28' as Expr1 UNION ALL
	SELECT '04:30' as Expr1 UNION ALL
	SELECT '04:32' as Expr1 UNION ALL
	SELECT '04:34' as Expr1 UNION ALL
	SELECT '04:36' as Expr1 UNION ALL
	SELECT '04:38' as Expr1 UNION ALL
	SELECT '04:40' as Expr1 UNION ALL
	SELECT '04:42' as Expr1 UNION ALL
	SELECT '04:44' as Expr1 UNION ALL
	SELECT '04:46' as Expr1 UNION ALL
	SELECT '04:48' as Expr1 UNION ALL
	SELECT '04:50' as Expr1 UNION ALL
	SELECT '04:52' as Expr1 UNION ALL
	SELECT '04:54' as Expr1 UNION ALL
	SELECT '04:56' as Expr1 UNION ALL
	SELECT '04:58' as Expr1 UNION ALL
	SELECT '05:00' as Expr1 UNION ALL
	SELECT '05:02' as Expr1 UNION ALL
	SELECT '05:04' as Expr1 UNION ALL
	SELECT '05:06' as Expr1 UNION ALL
	SELECT '05:08' as Expr1 UNION ALL
	SELECT '05:10' as Expr1 UNION ALL
	SELECT '05:12' as Expr1 UNION ALL
	SELECT '05:14' as Expr1 UNION ALL
	SELECT '05:16' as Expr1 UNION ALL
	SELECT '05:18' as Expr1 UNION ALL
	SELECT '05:20' as Expr1 UNION ALL
	SELECT '05:22' as Expr1 UNION ALL
	SELECT '05:24' as Expr1 UNION ALL
	SELECT '05:26' as Expr1 UNION ALL
	SELECT '05:28' as Expr1 UNION ALL
	SELECT '05:30' as Expr1 UNION ALL
	SELECT '05:32' as Expr1 UNION ALL
	SELECT '05:34' as Expr1 UNION ALL
	SELECT '05:36' as Expr1 UNION ALL
	SELECT '05:38' as Expr1 UNION ALL
	SELECT '05:40' as Expr1 UNION ALL
	SELECT '05:42' as Expr1 UNION ALL
	SELECT '05:44' as Expr1 UNION ALL
	SELECT '05:46' as Expr1 UNION ALL
	SELECT '05:48' as Expr1 UNION ALL
	SELECT '05:50' as Expr1 UNION ALL
	SELECT '05:52' as Expr1 UNION ALL
	SELECT '05:54' as Expr1 UNION ALL
	SELECT '05:56' as Expr1 UNION ALL
	SELECT '05:58' as Expr1 UNION ALL
	SELECT '06:00' as Expr1 UNION ALL
	SELECT '06:02' as Expr1 UNION ALL
	SELECT '06:04' as Expr1 UNION ALL
	SELECT '06:06' as Expr1 UNION ALL
	SELECT '06:08' as Expr1 UNION ALL
	SELECT '06:10' as Expr1 UNION ALL
	SELECT '06:12' as Expr1 UNION ALL
	SELECT '06:14' as Expr1 UNION ALL
	SELECT '06:16' as Expr1 UNION ALL
	SELECT '06:18' as Expr1 UNION ALL
	SELECT '06:20' as Expr1 UNION ALL
	SELECT '06:22' as Expr1 UNION ALL
	SELECT '06:24' as Expr1 UNION ALL
	SELECT '06:26' as Expr1 UNION ALL
	SELECT '06:28' as Expr1 UNION ALL
	SELECT '06:30' as Expr1 UNION ALL
	SELECT '06:32' as Expr1 UNION ALL
	SELECT '06:34' as Expr1 UNION ALL
	SELECT '06:36' as Expr1 UNION ALL
	SELECT '06:38' as Expr1 UNION ALL
	SELECT '06:40' as Expr1 UNION ALL
	SELECT '06:42' as Expr1 UNION ALL
	SELECT '06:44' as Expr1 UNION ALL
	SELECT '06:46' as Expr1 UNION ALL
	SELECT '06:48' as Expr1 UNION ALL
	SELECT '06:50' as Expr1 UNION ALL
	SELECT '06:52' as Expr1 UNION ALL
	SELECT '06:54' as Expr1 UNION ALL
	SELECT '06:56' as Expr1 UNION ALL
	SELECT '06:58' as Expr1 UNION ALL
	SELECT '07:00' as Expr1 UNION ALL
	SELECT '07:02' as Expr1 UNION ALL
	SELECT '07:04' as Expr1 UNION ALL
	SELECT '07:06' as Expr1 UNION ALL
	SELECT '07:08' as Expr1 UNION ALL
	SELECT '07:10' as Expr1 UNION ALL
	SELECT '07:12' as Expr1 UNION ALL
	SELECT '07:14' as Expr1 UNION ALL
	SELECT '07:16' as Expr1 UNION ALL
	SELECT '07:18' as Expr1 UNION ALL
	SELECT '07:20' as Expr1 UNION ALL
	SELECT '07:22' as Expr1 UNION ALL
	SELECT '07:24' as Expr1 UNION ALL
	SELECT '07:26' as Expr1 UNION ALL
	SELECT '07:28' as Expr1 UNION ALL
	SELECT '07:30' as Expr1 UNION ALL
	SELECT '07:32' as Expr1 UNION ALL
	SELECT '07:34' as Expr1 UNION ALL
	SELECT '07:36' as Expr1 UNION ALL
	SELECT '07:38' as Expr1 UNION ALL
	SELECT '07:40' as Expr1 UNION ALL
	SELECT '07:42' as Expr1 UNION ALL
	SELECT '07:44' as Expr1 UNION ALL
	SELECT '07:46' as Expr1 UNION ALL
	SELECT '07:48' as Expr1 UNION ALL
	SELECT '07:50' as Expr1 UNION ALL
	SELECT '07:52' as Expr1 UNION ALL
	SELECT '07:54' as Expr1 UNION ALL
	SELECT '07:56' as Expr1 UNION ALL
	SELECT '07:58' as Expr1 UNION ALL
	SELECT '08:00' as Expr1 UNION ALL
	SELECT '08:02' as Expr1 UNION ALL
	SELECT '08:04' as Expr1 UNION ALL
	SELECT '08:06' as Expr1 UNION ALL
	SELECT '08:08' as Expr1 UNION ALL
	SELECT '08:10' as Expr1 UNION ALL
	SELECT '08:12' as Expr1 UNION ALL
	SELECT '08:14' as Expr1 UNION ALL
	SELECT '08:16' as Expr1 UNION ALL
	SELECT '08:18' as Expr1 UNION ALL
	SELECT '08:20' as Expr1 UNION ALL
	SELECT '08:22' as Expr1 UNION ALL
	SELECT '08:24' as Expr1 UNION ALL
	SELECT '08:26' as Expr1 UNION ALL
	SELECT '08:28' as Expr1 UNION ALL
	SELECT '08:30' as Expr1 UNION ALL
	SELECT '08:32' as Expr1 UNION ALL
	SELECT '08:34' as Expr1 UNION ALL
	SELECT '08:36' as Expr1 UNION ALL
	SELECT '08:38' as Expr1 UNION ALL
	SELECT '08:40' as Expr1 UNION ALL
	SELECT '08:42' as Expr1 UNION ALL
	SELECT '08:44' as Expr1 UNION ALL
	SELECT '08:46' as Expr1 UNION ALL
	SELECT '08:48' as Expr1 UNION ALL
	SELECT '08:50' as Expr1 UNION ALL
	SELECT '08:52' as Expr1 UNION ALL
	SELECT '08:54' as Expr1 UNION ALL
	SELECT '08:56' as Expr1 UNION ALL
	SELECT '08:58' as Expr1 UNION ALL
	SELECT '09:00' as Expr1 UNION ALL
	SELECT '09:02' as Expr1 UNION ALL
	SELECT '09:04' as Expr1 UNION ALL
	SELECT '09:06' as Expr1 UNION ALL
	SELECT '09:08' as Expr1 UNION ALL
	SELECT '09:10' as Expr1 UNION ALL
	SELECT '09:12' as Expr1 UNION ALL
	SELECT '09:14' as Expr1 UNION ALL
	SELECT '09:16' as Expr1 UNION ALL
	SELECT '09:18' as Expr1 UNION ALL
	SELECT '09:20' as Expr1 UNION ALL
	SELECT '09:22' as Expr1 UNION ALL
	SELECT '09:24' as Expr1 UNION ALL
	SELECT '09:26' as Expr1 UNION ALL
	SELECT '09:28' as Expr1 UNION ALL
	SELECT '09:30' as Expr1 UNION ALL
	SELECT '09:32' as Expr1 UNION ALL
	SELECT '09:34' as Expr1 UNION ALL
	SELECT '09:36' as Expr1 UNION ALL
	SELECT '09:38' as Expr1 UNION ALL
	SELECT '09:40' as Expr1 UNION ALL
	SELECT '09:42' as Expr1 UNION ALL
	SELECT '09:44' as Expr1 UNION ALL
	SELECT '09:46' as Expr1 UNION ALL
	SELECT '09:48' as Expr1 UNION ALL
	SELECT '09:50' as Expr1 UNION ALL
	SELECT '09:52' as Expr1 UNION ALL
	SELECT '09:54' as Expr1 UNION ALL
	SELECT '09:56' as Expr1 UNION ALL
	SELECT '09:58' as Expr1 UNION ALL
	SELECT '10:00' as Expr1 UNION ALL
	SELECT '10:02' as Expr1 UNION ALL
	SELECT '10:04' as Expr1 UNION ALL
	SELECT '10:06' as Expr1 UNION ALL
	SELECT '10:08' as Expr1 UNION ALL
	SELECT '10:10' as Expr1 UNION ALL
	SELECT '10:12' as Expr1 UNION ALL
	SELECT '10:14' as Expr1 UNION ALL
	SELECT '10:16' as Expr1 UNION ALL
	SELECT '10:18' as Expr1 UNION ALL
	SELECT '10:20' as Expr1 UNION ALL
	SELECT '10:22' as Expr1 UNION ALL
	SELECT '10:24' as Expr1 UNION ALL
	SELECT '10:26' as Expr1 UNION ALL
	SELECT '10:28' as Expr1 UNION ALL
	SELECT '10:30' as Expr1 UNION ALL
	SELECT '10:32' as Expr1 UNION ALL
	SELECT '10:34' as Expr1 UNION ALL
	SELECT '10:36' as Expr1 UNION ALL
	SELECT '10:38' as Expr1 UNION ALL
	SELECT '10:40' as Expr1 UNION ALL
	SELECT '10:42' as Expr1 UNION ALL
	SELECT '10:44' as Expr1 UNION ALL
	SELECT '10:46' as Expr1 UNION ALL
	SELECT '10:48' as Expr1 UNION ALL
	SELECT '10:50' as Expr1 UNION ALL
	SELECT '10:52' as Expr1 UNION ALL
	SELECT '10:54' as Expr1 UNION ALL
	SELECT '10:56' as Expr1 UNION ALL
	SELECT '10:58' as Expr1 UNION ALL
	SELECT '11:00' as Expr1 UNION ALL
	SELECT '11:02' as Expr1 UNION ALL
	SELECT '11:04' as Expr1 UNION ALL
	SELECT '11:06' as Expr1 UNION ALL
	SELECT '11:08' as Expr1 UNION ALL
	SELECT '11:10' as Expr1 UNION ALL
	SELECT '11:12' as Expr1 UNION ALL
	SELECT '11:14' as Expr1 UNION ALL
	SELECT '11:16' as Expr1 UNION ALL
	SELECT '11:18' as Expr1 UNION ALL
	SELECT '11:20' as Expr1 UNION ALL
	SELECT '11:22' as Expr1 UNION ALL
	SELECT '11:24' as Expr1 UNION ALL
	SELECT '11:26' as Expr1 UNION ALL
	SELECT '11:28' as Expr1 UNION ALL
	SELECT '11:30' as Expr1 UNION ALL
	SELECT '11:32' as Expr1 UNION ALL
	SELECT '11:34' as Expr1 UNION ALL
	SELECT '11:36' as Expr1 UNION ALL
	SELECT '11:38' as Expr1 UNION ALL
	SELECT '11:40' as Expr1 UNION ALL
	SELECT '11:42' as Expr1 UNION ALL
	SELECT '11:44' as Expr1 UNION ALL
	SELECT '11:46' as Expr1 UNION ALL
	SELECT '11:48' as Expr1 UNION ALL
	SELECT '11:50' as Expr1 UNION ALL
	SELECT '11:52' as Expr1 UNION ALL
	SELECT '11:54' as Expr1 UNION ALL
	SELECT '11:56' as Expr1 UNION ALL
	SELECT '11:58' as Expr1 UNION ALL
	SELECT '12:00' as Expr1 UNION ALL
	SELECT '12:02' as Expr1 UNION ALL
	SELECT '12:04' as Expr1 UNION ALL
	SELECT '12:06' as Expr1 UNION ALL
	SELECT '12:08' as Expr1 UNION ALL
	SELECT '12:10' as Expr1 UNION ALL
	SELECT '12:12' as Expr1 UNION ALL
	SELECT '12:14' as Expr1 UNION ALL
	SELECT '12:16' as Expr1 UNION ALL
	SELECT '12:18' as Expr1 UNION ALL
	SELECT '12:20' as Expr1 UNION ALL
	SELECT '12:22' as Expr1 UNION ALL
	SELECT '12:24' as Expr1 UNION ALL
	SELECT '12:26' as Expr1 UNION ALL
	SELECT '12:28' as Expr1 UNION ALL
	SELECT '12:30' as Expr1 UNION ALL
	SELECT '12:32' as Expr1 UNION ALL
	SELECT '12:34' as Expr1 UNION ALL
	SELECT '12:36' as Expr1 UNION ALL
	SELECT '12:38' as Expr1 UNION ALL
	SELECT '12:40' as Expr1 UNION ALL
	SELECT '12:42' as Expr1 UNION ALL
	SELECT '12:44' as Expr1 UNION ALL
	SELECT '12:46' as Expr1 UNION ALL
	SELECT '12:48' as Expr1 UNION ALL
	SELECT '12:50' as Expr1 UNION ALL
	SELECT '12:52' as Expr1 UNION ALL
	SELECT '12:54' as Expr1 UNION ALL
	SELECT '12:56' as Expr1 UNION ALL
	SELECT '12:58' as Expr1 UNION ALL
	SELECT '13:00' as Expr1 UNION ALL
	SELECT '13:02' as Expr1 UNION ALL
	SELECT '13:04' as Expr1 UNION ALL
	SELECT '13:06' as Expr1 UNION ALL
	SELECT '13:08' as Expr1 UNION ALL
	SELECT '13:10' as Expr1 UNION ALL
	SELECT '13:12' as Expr1 UNION ALL
	SELECT '13:14' as Expr1 UNION ALL
	SELECT '13:16' as Expr1 UNION ALL
	SELECT '13:18' as Expr1 UNION ALL
	SELECT '13:20' as Expr1 UNION ALL
	SELECT '13:22' as Expr1 UNION ALL
	SELECT '13:24' as Expr1 UNION ALL
	SELECT '13:26' as Expr1 UNION ALL
	SELECT '13:28' as Expr1 UNION ALL
	SELECT '13:30' as Expr1 UNION ALL
	SELECT '13:32' as Expr1 UNION ALL
	SELECT '13:34' as Expr1 UNION ALL
	SELECT '13:36' as Expr1 UNION ALL
	SELECT '13:38' as Expr1 UNION ALL
	SELECT '13:40' as Expr1 UNION ALL
	SELECT '13:42' as Expr1 UNION ALL
	SELECT '13:44' as Expr1 UNION ALL
	SELECT '13:46' as Expr1 UNION ALL
	SELECT '13:48' as Expr1 UNION ALL
	SELECT '13:50' as Expr1 UNION ALL
	SELECT '13:52' as Expr1 UNION ALL
	SELECT '13:54' as Expr1 UNION ALL
	SELECT '13:56' as Expr1 UNION ALL
	SELECT '13:58' as Expr1 UNION ALL
	SELECT '14:00' as Expr1 UNION ALL
	SELECT '14:02' as Expr1 UNION ALL
	SELECT '14:04' as Expr1 UNION ALL
	SELECT '14:06' as Expr1 UNION ALL
	SELECT '14:08' as Expr1 UNION ALL
	SELECT '14:10' as Expr1 UNION ALL
	SELECT '14:12' as Expr1 UNION ALL
	SELECT '14:14' as Expr1 UNION ALL
	SELECT '14:16' as Expr1 UNION ALL
	SELECT '14:18' as Expr1 UNION ALL
	SELECT '14:20' as Expr1 UNION ALL
	SELECT '14:22' as Expr1 UNION ALL
	SELECT '14:24' as Expr1 UNION ALL
	SELECT '14:26' as Expr1 UNION ALL
	SELECT '14:28' as Expr1 UNION ALL
	SELECT '14:30' as Expr1 UNION ALL
	SELECT '14:32' as Expr1 UNION ALL
	SELECT '14:34' as Expr1 UNION ALL
	SELECT '14:36' as Expr1 UNION ALL
	SELECT '14:38' as Expr1 UNION ALL
	SELECT '14:40' as Expr1 UNION ALL
	SELECT '14:42' as Expr1 UNION ALL
	SELECT '14:44' as Expr1 UNION ALL
	SELECT '14:46' as Expr1 UNION ALL
	SELECT '14:48' as Expr1 UNION ALL
	SELECT '14:50' as Expr1 UNION ALL
	SELECT '14:52' as Expr1 UNION ALL
	SELECT '14:54' as Expr1 UNION ALL
	SELECT '14:56' as Expr1 UNION ALL
	SELECT '14:58' as Expr1 UNION ALL
	SELECT '15:00' as Expr1 UNION ALL
	SELECT '15:02' as Expr1 UNION ALL
	SELECT '15:04' as Expr1 UNION ALL
	SELECT '15:06' as Expr1 UNION ALL
	SELECT '15:08' as Expr1 UNION ALL
	SELECT '15:10' as Expr1 UNION ALL
	SELECT '15:12' as Expr1 UNION ALL
	SELECT '15:14' as Expr1 UNION ALL
	SELECT '15:16' as Expr1 UNION ALL
	SELECT '15:18' as Expr1 UNION ALL
	SELECT '15:20' as Expr1 UNION ALL
	SELECT '15:22' as Expr1 UNION ALL
	SELECT '15:24' as Expr1 UNION ALL
	SELECT '15:26' as Expr1 UNION ALL
	SELECT '15:28' as Expr1 UNION ALL
	SELECT '15:30' as Expr1 UNION ALL
	SELECT '15:32' as Expr1 UNION ALL
	SELECT '15:34' as Expr1 UNION ALL
	SELECT '15:36' as Expr1 UNION ALL
	SELECT '15:38' as Expr1 UNION ALL
	SELECT '15:40' as Expr1 UNION ALL
	SELECT '15:42' as Expr1 UNION ALL
	SELECT '15:44' as Expr1 UNION ALL
	SELECT '15:46' as Expr1 UNION ALL
	SELECT '15:48' as Expr1 UNION ALL
	SELECT '15:50' as Expr1 UNION ALL
	SELECT '15:52' as Expr1 UNION ALL
	SELECT '15:54' as Expr1 UNION ALL
	SELECT '15:56' as Expr1 UNION ALL
	SELECT '15:58' as Expr1 UNION ALL
	SELECT '16:00' as Expr1 UNION ALL
	SELECT '16:02' as Expr1 UNION ALL
	SELECT '16:04' as Expr1 UNION ALL
	SELECT '16:06' as Expr1 UNION ALL
	SELECT '16:08' as Expr1 UNION ALL
	SELECT '16:10' as Expr1 UNION ALL
	SELECT '16:12' as Expr1 UNION ALL
	SELECT '16:14' as Expr1 UNION ALL
	SELECT '16:16' as Expr1 UNION ALL
	SELECT '16:18' as Expr1 UNION ALL
	SELECT '16:20' as Expr1 UNION ALL
	SELECT '16:22' as Expr1 UNION ALL
	SELECT '16:24' as Expr1 UNION ALL
	SELECT '16:26' as Expr1 UNION ALL
	SELECT '16:28' as Expr1 UNION ALL
	SELECT '16:30' as Expr1 UNION ALL
	SELECT '16:32' as Expr1 UNION ALL
	SELECT '16:34' as Expr1 UNION ALL
	SELECT '16:36' as Expr1 UNION ALL
	SELECT '16:38' as Expr1 UNION ALL
	SELECT '16:40' as Expr1 UNION ALL
	SELECT '16:42' as Expr1 UNION ALL
	SELECT '16:44' as Expr1 UNION ALL
	SELECT '16:46' as Expr1 UNION ALL
	SELECT '16:48' as Expr1 UNION ALL
	SELECT '16:50' as Expr1 UNION ALL
	SELECT '16:52' as Expr1 UNION ALL
	SELECT '16:54' as Expr1 UNION ALL
	SELECT '16:56' as Expr1 UNION ALL
	SELECT '16:58' as Expr1 UNION ALL
	SELECT '17:00' as Expr1 UNION ALL
	SELECT '17:02' as Expr1 UNION ALL
	SELECT '17:04' as Expr1 UNION ALL
	SELECT '17:06' as Expr1 UNION ALL
	SELECT '17:08' as Expr1 UNION ALL
	SELECT '17:10' as Expr1 UNION ALL
	SELECT '17:12' as Expr1 UNION ALL
	SELECT '17:14' as Expr1 UNION ALL
	SELECT '17:16' as Expr1 UNION ALL
	SELECT '17:18' as Expr1 UNION ALL
	SELECT '17:20' as Expr1 UNION ALL
	SELECT '17:22' as Expr1 UNION ALL
	SELECT '17:24' as Expr1 UNION ALL
	SELECT '17:26' as Expr1 UNION ALL
	SELECT '17:28' as Expr1 UNION ALL
	SELECT '17:30' as Expr1 UNION ALL
	SELECT '17:32' as Expr1 UNION ALL
	SELECT '17:34' as Expr1 UNION ALL
	SELECT '17:36' as Expr1 UNION ALL
	SELECT '17:38' as Expr1 UNION ALL
	SELECT '17:40' as Expr1 UNION ALL
	SELECT '17:42' as Expr1 UNION ALL
	SELECT '17:44' as Expr1 UNION ALL
	SELECT '17:46' as Expr1 UNION ALL
	SELECT '17:48' as Expr1 UNION ALL
	SELECT '17:50' as Expr1 UNION ALL
	SELECT '17:52' as Expr1 UNION ALL
	SELECT '17:54' as Expr1 UNION ALL
	SELECT '17:56' as Expr1 UNION ALL
	SELECT '17:58' as Expr1 UNION ALL
	SELECT '18:00' as Expr1 UNION ALL
	SELECT '18:02' as Expr1 UNION ALL
	SELECT '18:04' as Expr1 UNION ALL
	SELECT '18:06' as Expr1 UNION ALL
	SELECT '18:08' as Expr1 UNION ALL
	SELECT '18:10' as Expr1 UNION ALL
	SELECT '18:12' as Expr1 UNION ALL
	SELECT '18:14' as Expr1 UNION ALL
	SELECT '18:16' as Expr1 UNION ALL
	SELECT '18:18' as Expr1 UNION ALL
	SELECT '18:20' as Expr1 UNION ALL
	SELECT '18:22' as Expr1 UNION ALL
	SELECT '18:24' as Expr1 UNION ALL
	SELECT '18:26' as Expr1 UNION ALL
	SELECT '18:28' as Expr1 UNION ALL
	SELECT '18:30' as Expr1 UNION ALL
	SELECT '18:32' as Expr1 UNION ALL
	SELECT '18:34' as Expr1 UNION ALL
	SELECT '18:36' as Expr1 UNION ALL
	SELECT '18:38' as Expr1 UNION ALL
	SELECT '18:40' as Expr1 UNION ALL
	SELECT '18:42' as Expr1 UNION ALL
	SELECT '18:44' as Expr1 UNION ALL
	SELECT '18:46' as Expr1 UNION ALL
	SELECT '18:48' as Expr1 UNION ALL
	SELECT '18:50' as Expr1 UNION ALL
	SELECT '18:52' as Expr1 UNION ALL
	SELECT '18:54' as Expr1 UNION ALL
	SELECT '18:56' as Expr1 UNION ALL
	SELECT '18:58' as Expr1 UNION ALL
	SELECT '19:00' as Expr1 UNION ALL
	SELECT '19:02' as Expr1 UNION ALL
	SELECT '19:04' as Expr1 UNION ALL
	SELECT '19:06' as Expr1 UNION ALL
	SELECT '19:08' as Expr1 UNION ALL
	SELECT '19:10' as Expr1 UNION ALL
	SELECT '19:12' as Expr1 UNION ALL
	SELECT '19:14' as Expr1 UNION ALL
	SELECT '19:16' as Expr1 UNION ALL
	SELECT '19:18' as Expr1 UNION ALL
	SELECT '19:20' as Expr1 UNION ALL
	SELECT '19:22' as Expr1 UNION ALL
	SELECT '19:24' as Expr1 UNION ALL
	SELECT '19:26' as Expr1 UNION ALL
	SELECT '19:28' as Expr1 UNION ALL
	SELECT '19:30' as Expr1 UNION ALL
	SELECT '19:32' as Expr1 UNION ALL
	SELECT '19:34' as Expr1 UNION ALL
	SELECT '19:36' as Expr1 UNION ALL
	SELECT '19:38' as Expr1 UNION ALL
	SELECT '19:40' as Expr1 UNION ALL
	SELECT '19:42' as Expr1 UNION ALL
	SELECT '19:44' as Expr1 UNION ALL
	SELECT '19:46' as Expr1 UNION ALL
	SELECT '19:48' as Expr1 UNION ALL
	SELECT '19:50' as Expr1 UNION ALL
	SELECT '19:52' as Expr1 UNION ALL
	SELECT '19:54' as Expr1 UNION ALL
	SELECT '19:56' as Expr1 UNION ALL
	SELECT '19:58' as Expr1 UNION ALL
	SELECT '20:00' as Expr1 UNION ALL
	SELECT '20:02' as Expr1 UNION ALL
	SELECT '20:04' as Expr1 UNION ALL
	SELECT '20:06' as Expr1 UNION ALL
	SELECT '20:08' as Expr1 UNION ALL
	SELECT '20:10' as Expr1 UNION ALL
	SELECT '20:12' as Expr1 UNION ALL
	SELECT '20:14' as Expr1 UNION ALL
	SELECT '20:16' as Expr1 UNION ALL
	SELECT '20:18' as Expr1 UNION ALL
	SELECT '20:20' as Expr1 UNION ALL
	SELECT '20:22' as Expr1 UNION ALL
	SELECT '20:24' as Expr1 UNION ALL
	SELECT '20:26' as Expr1 UNION ALL
	SELECT '20:28' as Expr1 UNION ALL
	SELECT '20:30' as Expr1 UNION ALL
	SELECT '20:32' as Expr1 UNION ALL
	SELECT '20:34' as Expr1 UNION ALL
	SELECT '20:36' as Expr1 UNION ALL
	SELECT '20:38' as Expr1 UNION ALL
	SELECT '20:40' as Expr1 UNION ALL
	SELECT '20:42' as Expr1 UNION ALL
	SELECT '20:44' as Expr1 UNION ALL
	SELECT '20:46' as Expr1 UNION ALL
	SELECT '20:48' as Expr1 UNION ALL
	SELECT '20:50' as Expr1 UNION ALL
	SELECT '20:52' as Expr1 UNION ALL
	SELECT '20:54' as Expr1 UNION ALL
	SELECT '20:56' as Expr1 UNION ALL
	SELECT '20:58' as Expr1 UNION ALL
	SELECT '21:00' as Expr1 UNION ALL
	SELECT '21:02' as Expr1 UNION ALL
	SELECT '21:04' as Expr1 UNION ALL
	SELECT '21:06' as Expr1 UNION ALL
	SELECT '21:08' as Expr1 UNION ALL
	SELECT '21:10' as Expr1 UNION ALL
	SELECT '21:12' as Expr1 UNION ALL
	SELECT '21:14' as Expr1 UNION ALL
	SELECT '21:16' as Expr1 UNION ALL
	SELECT '21:18' as Expr1 UNION ALL
	SELECT '21:20' as Expr1 UNION ALL
	SELECT '21:22' as Expr1 UNION ALL
	SELECT '21:24' as Expr1 UNION ALL
	SELECT '21:26' as Expr1 UNION ALL
	SELECT '21:28' as Expr1 UNION ALL
	SELECT '21:30' as Expr1 UNION ALL
	SELECT '21:32' as Expr1 UNION ALL
	SELECT '21:34' as Expr1 UNION ALL
	SELECT '21:36' as Expr1 UNION ALL
	SELECT '21:38' as Expr1 UNION ALL
	SELECT '21:40' as Expr1 UNION ALL
	SELECT '21:42' as Expr1 UNION ALL
	SELECT '21:44' as Expr1 UNION ALL
	SELECT '21:46' as Expr1 UNION ALL
	SELECT '21:48' as Expr1 UNION ALL
	SELECT '21:50' as Expr1 UNION ALL
	SELECT '21:52' as Expr1 UNION ALL
	SELECT '21:54' as Expr1 UNION ALL
	SELECT '21:56' as Expr1 UNION ALL
	SELECT '21:58' as Expr1 UNION ALL
	SELECT '22:00' as Expr1 UNION ALL
	SELECT '22:02' as Expr1 UNION ALL
	SELECT '22:04' as Expr1 UNION ALL
	SELECT '22:06' as Expr1 UNION ALL
	SELECT '22:08' as Expr1 UNION ALL
	SELECT '22:10' as Expr1 UNION ALL
	SELECT '22:12' as Expr1 UNION ALL
	SELECT '22:14' as Expr1 UNION ALL
	SELECT '22:16' as Expr1 UNION ALL
	SELECT '22:18' as Expr1 UNION ALL
	SELECT '22:20' as Expr1 UNION ALL
	SELECT '22:22' as Expr1 UNION ALL
	SELECT '22:24' as Expr1 UNION ALL
	SELECT '22:26' as Expr1 UNION ALL
	SELECT '22:28' as Expr1 UNION ALL
	SELECT '22:30' as Expr1 UNION ALL
	SELECT '22:32' as Expr1 UNION ALL
	SELECT '22:34' as Expr1 UNION ALL
	SELECT '22:36' as Expr1 UNION ALL
	SELECT '22:38' as Expr1 UNION ALL
	SELECT '22:40' as Expr1 UNION ALL
	SELECT '22:42' as Expr1 UNION ALL
	SELECT '22:44' as Expr1 UNION ALL
	SELECT '22:46' as Expr1 UNION ALL
	SELECT '22:48' as Expr1 UNION ALL
	SELECT '22:50' as Expr1 UNION ALL
	SELECT '22:52' as Expr1 UNION ALL
	SELECT '22:54' as Expr1 UNION ALL
	SELECT '22:56' as Expr1 UNION ALL
	SELECT '22:58' as Expr1 UNION ALL
	SELECT '23:00' as Expr1 UNION ALL
	SELECT '23:02' as Expr1 UNION ALL
	SELECT '23:04' as Expr1 UNION ALL
	SELECT '23:06' as Expr1 UNION ALL
	SELECT '23:08' as Expr1 UNION ALL
	SELECT '23:10' as Expr1 UNION ALL
	SELECT '23:12' as Expr1 UNION ALL
	SELECT '23:14' as Expr1 UNION ALL
	SELECT '23:16' as Expr1 UNION ALL
	SELECT '23:18' as Expr1 UNION ALL
	SELECT '23:20' as Expr1 UNION ALL
	SELECT '23:22' as Expr1 UNION ALL
	SELECT '23:24' as Expr1 UNION ALL
	SELECT '23:26' as Expr1 UNION ALL
	SELECT '23:28' as Expr1 UNION ALL
	SELECT '23:30' as Expr1 UNION ALL
	SELECT '23:32' as Expr1 UNION ALL
	SELECT '23:34' as Expr1 UNION ALL
	SELECT '23:36' as Expr1 UNION ALL
	SELECT '23:38' as Expr1 UNION ALL
	SELECT '23:40' as Expr1 UNION ALL
	SELECT '23:42' as Expr1 UNION ALL
	SELECT '23:44' as Expr1 UNION ALL
	SELECT '23:46' as Expr1 UNION ALL
	SELECT '23:48' as Expr1 UNION ALL
	SELECT '23:50' as Expr1 UNION ALL
	SELECT '23:52' as Expr1 UNION ALL
	SELECT '23:54' as Expr1 UNION ALL
	SELECT '23:56' as Expr1 UNION ALL
	SELECT '23:58' as Expr1
	)  LK_HORAS
	ON (LK_HORAS.Expr1=case when substring(a.hour,1,2)='24' then '00'+substring(a.hour,3,3) else a.hour end)
  )  Sales_hour_physical_channel
GROUP BY
  Sales_hour_physical_channel.BD,
  Sales_hour_physical_channel.channel_lvl1,
  Sales_hour_physical_channel.channelLvl2,
  Sales_hour_physical_channel.Expr1,
  left(Sales_hour_physical_channel.Expr1,2))C1

UNION ALL

SELECT C2.DAY, C2.HORA, C2.channel_lvl1, C2.channelLvl2, C2.DATOS

FROM (
SELECT
  'Last Week' as 'DAY',
  Sales_hour_physical_cannel_prev_week.BD,
  Sales_hour_physical_cannel_prev_week.hour,
  Sales_hour_physical_cannel_prev_week.channel_lvl1,
  Sales_hour_physical_cannel_prev_week.channelLvl2,
  sum(Sales_hour_physical_cannel_prev_week.bookings) DATOS,
  Sales_hour_physical_cannel_prev_week.Expr1,
  left(Sales_hour_physical_cannel_prev_week.Expr1,2) HORA
FROM
  (
  select *
from (

	select
	CONVERT(nvarchar(8), DATEADD(minute,TimeZoneVariation.Variation,i.BookingUTC),112) as BD,
	RIGHT('00'+CAST (DATEPART(hour,DATEADD(minute,TimeZoneVariation.Variation,i.BookingUTC)) AS VARCHAR(2)),2)+':'+
		substring(convert(nvarchar,dateadd(MINUTE,substring(convert(varchar,CONVERT(time, i.BookingUTC)),5,1)%2,i.BookingUTC),120),15,2) as  hour,

	---------------- CHANNEL_LVL1 --------------------
	case when i.ChannelType = 1 then 'DIRECT'
		when i.ChannelType = 2 then 'WEB'
		when i.ChannelType = 3 then 'GDS'
		when i.ChannelType = 4 then 'API'
		else 'OTROS' end as channel_lvl1,
	---------------- CHANNEL_LVL2 --------------------
	case when i.ChannelType = 1 and l.locationType = 1 then 'AIRPORT'
		when i.ChannelType = 1 and l.locationType = 0 and a.DepartmentCode = 'CC' and l.LocationCode not in ('HDQ') then 'CC'
		when i.ChannelType = 1 and l.locationType = 0 and l.LocationCode in ('HDQ') then 'HDQ'
		when i.ChannelType = 1 and l.locationType = 0   then 'OTROS'

		when i.ChannelType = 2 and i.CreatedLocationCode in ('SYS','WWW') then 'VY.COM'
		when i.ChannelType = 2 and i.CreatedLocationCode in ('AGD','BSP','VLG','AGET ') then 'B2B'
		when i.ChannelType = 2 and i.CreatedLocationCode in ('LWEB') then 'FLYLEVEL.COM'
		when i.ChannelType = 2 then 'OTROS'

		when i.ChannelType = 3 and br.OwningSystemCode ='1A' then 'AMADEUS'
		when i.ChannelType = 3 and br.OwningSystemCode ='1G' then 'GALILEO'
		when i.ChannelType = 3 and br.OwningSystemCode ='1P' then 'WORLDSPAN'
		when i.ChannelType = 3 and br.OwningSystemCode ='IB' then 'CODEIB'
		when i.ChannelType = 3 and br.OwningSystemCode ='BA' then 'CODEBA'
		when i.ChannelType = 3 and br.OwningSystemCode ='1S' then 'SABRE'
		when i.ChannelType = 3 and br.OwningSystemCode ='1V' then 'APOLLO'
		when i.ChannelType = 3 and i.CreatedLocationCode = 'GDS' and br.OwningSystemCode = 'X3'  THEN 'TUIFLY'
		when i.ChannelType = 3 then 'OTROS'

		when i.ChannelType = 4 and i.CreatedUserCode ='APIG' OR i.CreatedUserCode like 'GR-%' then 'GROUPS'
		when i.ChannelType = 4 and i.CreatedUserCode ='TTOOAPI' then 'TTOO'
		when i.ChannelType = 4 and i.receivedBy like '%#VY#NDC'  then 'NDC'
		when i.ChannelType = 4 and i.CreatedUserCode like 'I3%' and i.CreatedUserCode not like  ('I3-mo2o%') then 'I3'
		when i.ChannelType = 4 and (i.CreatedUserCode like  ('I3-mo2o%') or i.CreatedUserCode in ('PortalWeb','AppIOS','AppW8','AppAndroid','AppBB','AppWP')) then 'MOBIL'
		when i.ChannelType = 4 and i.CreatedUserCode  = 'ApiIntra' then 'INTRANET'
		when i.ChannelType = 4 then 'OTROS'
		else 'NO APLICA'
	end as channelLvl2,
	count(*) as bookings
	from rez.booking i
		left join rez.location l on i.createdlocationcode = l.locationcode
		join rez.agent a on i.createdUserid=a.AgentID
		left join rez.BookingRecordLocator br on i.bookingId=br.bookingid
		inner join TimeZoneVariation on GETDATE() BETWEEN TimeZoneVariation.StartUTC AND TimeZoneVariation.EndUTC and  TimeZoneVariation.TimeZoneCode = 'ES1'
	where i.BookingUTC BETWEEN CONVERT(date, getDate()-8) AND CONVERT(date, DateAdd("d",1,getDate()-7))
		and  i.BookingUTC >= dateadd(MINUTE,TimeZoneVariation.Variation * -1,convert(nvarchar,GETDATE()-7,112))
	group by
	CONVERT(nvarchar(8), DATEADD(minute,TimeZoneVariation.Variation,i.BookingUTC),112),
	RIGHT('00'+CAST (DATEPART(hour,DATEADD(minute,TimeZoneVariation.Variation,i.BookingUTC)) AS VARCHAR(2)),2)+':'+
		substring(convert(nvarchar,dateadd(MINUTE,substring(convert(varchar,CONVERT(time, i.BookingUTC)),5,1)%2,i.BookingUTC),120),15,2),

	---------------- CHANNEL_LVL1 --------------------
	case when i.ChannelType = 1 then 'DIRECT'
		when i.ChannelType = 2 then 'WEB'
		when i.ChannelType = 3 then 'GDS'
		when i.ChannelType = 4 then 'API'
		else 'OTROS' end,
	---------------- CHANNEL_LVL2 --------------------
	case when i.ChannelType = 1 and l.locationType = 1 then 'AIRPORT'
		when i.ChannelType = 1 and l.locationType = 0 and a.DepartmentCode = 'CC' and l.LocationCode not in ('HDQ') then 'CC'
		when i.ChannelType = 1 and l.locationType = 0 and l.LocationCode in ('HDQ') then 'HDQ'
		when i.ChannelType = 1 and l.locationType = 0   then 'OTROS'

		when i.ChannelType = 2 and i.CreatedLocationCode in ('SYS','WWW') then 'VY.COM'
		when i.ChannelType = 2 and i.CreatedLocationCode in ('AGD','BSP','VLG','AGET ') then 'B2B'
		when i.ChannelType = 2 and i.CreatedLocationCode in ('LWEB') then 'FLYLEVEL.COM'
		when i.ChannelType = 2 then 'OTROS'

		when i.ChannelType = 3 and br.OwningSystemCode ='1A' then 'AMADEUS'
		when i.ChannelType = 3 and br.OwningSystemCode ='1G' then 'GALILEO'
		when i.ChannelType = 3 and br.OwningSystemCode ='1P' then 'WORLDSPAN'
		when i.ChannelType = 3 and br.OwningSystemCode ='IB' then 'CODEIB'
		when i.ChannelType = 3 and br.OwningSystemCode ='BA' then 'CODEBA'
		when i.ChannelType = 3 and br.OwningSystemCode ='1S' then 'SABRE'
		when i.ChannelType = 3 and br.OwningSystemCode ='1V' then 'APOLLO'
		when i.ChannelType = 3 and i.CreatedLocationCode = 'GDS' and br.OwningSystemCode = 'X3'  THEN 'TUIFLY'
		when i.ChannelType = 3 then 'OTROS'

		when i.ChannelType = 4 and i.CreatedUserCode ='APIG' OR i.CreatedUserCode like 'GR-%' then 'GROUPS'
		when i.ChannelType = 4 and i.CreatedUserCode ='TTOOAPI' then 'TTOO'
		when i.ChannelType = 4 and i.receivedBy like '%#VY#NDC'  then 'NDC'
		when i.ChannelType = 4 and i.CreatedUserCode like 'I3%' and i.CreatedUserCode not like  ('I3-mo2o%') then 'I3'
		when i.ChannelType = 4 and (i.CreatedUserCode like  ('I3-mo2o%') or i.CreatedUserCode in ('PortalWeb','AppIOS','AppW8','AppAndroid','AppBB','AppWP')) then 'MOBIL'
		when i.ChannelType = 4 and i.CreatedUserCode  = 'ApiIntra' then 'INTRANET'
		when i.ChannelType = 4 then 'OTROS'
		else 'NO APLICA'
	end
	) a
	right join
	(
	SELECT '00:00' as Expr1 UNION ALL
	SELECT '00:02' as Expr1 UNION ALL
	SELECT '00:04' as Expr1 UNION ALL
	SELECT '00:06' as Expr1 UNION ALL
	SELECT '00:08' as Expr1 UNION ALL
	SELECT '00:10' as Expr1 UNION ALL
	SELECT '00:12' as Expr1 UNION ALL
	SELECT '00:14' as Expr1 UNION ALL
	SELECT '00:16' as Expr1 UNION ALL
	SELECT '00:18' as Expr1 UNION ALL
	SELECT '00:20' as Expr1 UNION ALL
	SELECT '00:22' as Expr1 UNION ALL
	SELECT '00:24' as Expr1 UNION ALL
	SELECT '00:26' as Expr1 UNION ALL
	SELECT '00:28' as Expr1 UNION ALL
	SELECT '00:30' as Expr1 UNION ALL
	SELECT '00:32' as Expr1 UNION ALL
	SELECT '00:34' as Expr1 UNION ALL
	SELECT '00:36' as Expr1 UNION ALL
	SELECT '00:38' as Expr1 UNION ALL
	SELECT '00:40' as Expr1 UNION ALL
	SELECT '00:42' as Expr1 UNION ALL
	SELECT '00:44' as Expr1 UNION ALL
	SELECT '00:46' as Expr1 UNION ALL
	SELECT '00:48' as Expr1 UNION ALL
	SELECT '00:50' as Expr1 UNION ALL
	SELECT '00:52' as Expr1 UNION ALL
	SELECT '00:54' as Expr1 UNION ALL
	SELECT '00:56' as Expr1 UNION ALL
	SELECT '00:58' as Expr1 UNION ALL
	SELECT '01:00' as Expr1 UNION ALL
	SELECT '01:02' as Expr1 UNION ALL
	SELECT '01:04' as Expr1 UNION ALL
	SELECT '01:06' as Expr1 UNION ALL
	SELECT '01:08' as Expr1 UNION ALL
	SELECT '01:10' as Expr1 UNION ALL
	SELECT '01:12' as Expr1 UNION ALL
	SELECT '01:14' as Expr1 UNION ALL
	SELECT '01:16' as Expr1 UNION ALL
	SELECT '01:18' as Expr1 UNION ALL
	SELECT '01:20' as Expr1 UNION ALL
	SELECT '01:22' as Expr1 UNION ALL
	SELECT '01:24' as Expr1 UNION ALL
	SELECT '01:26' as Expr1 UNION ALL
	SELECT '01:28' as Expr1 UNION ALL
	SELECT '01:30' as Expr1 UNION ALL
	SELECT '01:32' as Expr1 UNION ALL
	SELECT '01:34' as Expr1 UNION ALL
	SELECT '01:36' as Expr1 UNION ALL
	SELECT '01:38' as Expr1 UNION ALL
	SELECT '01:40' as Expr1 UNION ALL
	SELECT '01:42' as Expr1 UNION ALL
	SELECT '01:44' as Expr1 UNION ALL
	SELECT '01:46' as Expr1 UNION ALL
	SELECT '01:48' as Expr1 UNION ALL
	SELECT '01:50' as Expr1 UNION ALL
	SELECT '01:52' as Expr1 UNION ALL
	SELECT '01:54' as Expr1 UNION ALL
	SELECT '01:56' as Expr1 UNION ALL
	SELECT '01:58' as Expr1 UNION ALL
	SELECT '02:00' as Expr1 UNION ALL
	SELECT '02:02' as Expr1 UNION ALL
	SELECT '02:04' as Expr1 UNION ALL
	SELECT '02:06' as Expr1 UNION ALL
	SELECT '02:08' as Expr1 UNION ALL
	SELECT '02:10' as Expr1 UNION ALL
	SELECT '02:12' as Expr1 UNION ALL
	SELECT '02:14' as Expr1 UNION ALL
	SELECT '02:16' as Expr1 UNION ALL
	SELECT '02:18' as Expr1 UNION ALL
	SELECT '02:20' as Expr1 UNION ALL
	SELECT '02:22' as Expr1 UNION ALL
	SELECT '02:24' as Expr1 UNION ALL
	SELECT '02:26' as Expr1 UNION ALL
	SELECT '02:28' as Expr1 UNION ALL
	SELECT '02:30' as Expr1 UNION ALL
	SELECT '02:32' as Expr1 UNION ALL
	SELECT '02:34' as Expr1 UNION ALL
	SELECT '02:36' as Expr1 UNION ALL
	SELECT '02:38' as Expr1 UNION ALL
	SELECT '02:40' as Expr1 UNION ALL
	SELECT '02:42' as Expr1 UNION ALL
	SELECT '02:44' as Expr1 UNION ALL
	SELECT '02:46' as Expr1 UNION ALL
	SELECT '02:48' as Expr1 UNION ALL
	SELECT '02:50' as Expr1 UNION ALL
	SELECT '02:52' as Expr1 UNION ALL
	SELECT '02:54' as Expr1 UNION ALL
	SELECT '02:56' as Expr1 UNION ALL
	SELECT '02:58' as Expr1 UNION ALL
	SELECT '03:00' as Expr1 UNION ALL
	SELECT '03:02' as Expr1 UNION ALL
	SELECT '03:04' as Expr1 UNION ALL
	SELECT '03:06' as Expr1 UNION ALL
	SELECT '03:08' as Expr1 UNION ALL
	SELECT '03:10' as Expr1 UNION ALL
	SELECT '03:12' as Expr1 UNION ALL
	SELECT '03:14' as Expr1 UNION ALL
	SELECT '03:16' as Expr1 UNION ALL
	SELECT '03:18' as Expr1 UNION ALL
	SELECT '03:20' as Expr1 UNION ALL
	SELECT '03:22' as Expr1 UNION ALL
	SELECT '03:24' as Expr1 UNION ALL
	SELECT '03:26' as Expr1 UNION ALL
	SELECT '03:28' as Expr1 UNION ALL
	SELECT '03:30' as Expr1 UNION ALL
	SELECT '03:32' as Expr1 UNION ALL
	SELECT '03:34' as Expr1 UNION ALL
	SELECT '03:36' as Expr1 UNION ALL
	SELECT '03:38' as Expr1 UNION ALL
	SELECT '03:40' as Expr1 UNION ALL
	SELECT '03:42' as Expr1 UNION ALL
	SELECT '03:44' as Expr1 UNION ALL
	SELECT '03:46' as Expr1 UNION ALL
	SELECT '03:48' as Expr1 UNION ALL
	SELECT '03:50' as Expr1 UNION ALL
	SELECT '03:52' as Expr1 UNION ALL
	SELECT '03:54' as Expr1 UNION ALL
	SELECT '03:56' as Expr1 UNION ALL
	SELECT '03:58' as Expr1 UNION ALL
	SELECT '04:00' as Expr1 UNION ALL
	SELECT '04:02' as Expr1 UNION ALL
	SELECT '04:04' as Expr1 UNION ALL
	SELECT '04:06' as Expr1 UNION ALL
	SELECT '04:08' as Expr1 UNION ALL
	SELECT '04:10' as Expr1 UNION ALL
	SELECT '04:12' as Expr1 UNION ALL
	SELECT '04:14' as Expr1 UNION ALL
	SELECT '04:16' as Expr1 UNION ALL
	SELECT '04:18' as Expr1 UNION ALL
	SELECT '04:20' as Expr1 UNION ALL
	SELECT '04:22' as Expr1 UNION ALL
	SELECT '04:24' as Expr1 UNION ALL
	SELECT '04:26' as Expr1 UNION ALL
	SELECT '04:28' as Expr1 UNION ALL
	SELECT '04:30' as Expr1 UNION ALL
	SELECT '04:32' as Expr1 UNION ALL
	SELECT '04:34' as Expr1 UNION ALL
	SELECT '04:36' as Expr1 UNION ALL
	SELECT '04:38' as Expr1 UNION ALL
	SELECT '04:40' as Expr1 UNION ALL
	SELECT '04:42' as Expr1 UNION ALL
	SELECT '04:44' as Expr1 UNION ALL
	SELECT '04:46' as Expr1 UNION ALL
	SELECT '04:48' as Expr1 UNION ALL
	SELECT '04:50' as Expr1 UNION ALL
	SELECT '04:52' as Expr1 UNION ALL
	SELECT '04:54' as Expr1 UNION ALL
	SELECT '04:56' as Expr1 UNION ALL
	SELECT '04:58' as Expr1 UNION ALL
	SELECT '05:00' as Expr1 UNION ALL
	SELECT '05:02' as Expr1 UNION ALL
	SELECT '05:04' as Expr1 UNION ALL
	SELECT '05:06' as Expr1 UNION ALL
	SELECT '05:08' as Expr1 UNION ALL
	SELECT '05:10' as Expr1 UNION ALL
	SELECT '05:12' as Expr1 UNION ALL
	SELECT '05:14' as Expr1 UNION ALL
	SELECT '05:16' as Expr1 UNION ALL
	SELECT '05:18' as Expr1 UNION ALL
	SELECT '05:20' as Expr1 UNION ALL
	SELECT '05:22' as Expr1 UNION ALL
	SELECT '05:24' as Expr1 UNION ALL
	SELECT '05:26' as Expr1 UNION ALL
	SELECT '05:28' as Expr1 UNION ALL
	SELECT '05:30' as Expr1 UNION ALL
	SELECT '05:32' as Expr1 UNION ALL
	SELECT '05:34' as Expr1 UNION ALL
	SELECT '05:36' as Expr1 UNION ALL
	SELECT '05:38' as Expr1 UNION ALL
	SELECT '05:40' as Expr1 UNION ALL
	SELECT '05:42' as Expr1 UNION ALL
	SELECT '05:44' as Expr1 UNION ALL
	SELECT '05:46' as Expr1 UNION ALL
	SELECT '05:48' as Expr1 UNION ALL
	SELECT '05:50' as Expr1 UNION ALL
	SELECT '05:52' as Expr1 UNION ALL
	SELECT '05:54' as Expr1 UNION ALL
	SELECT '05:56' as Expr1 UNION ALL
	SELECT '05:58' as Expr1 UNION ALL
	SELECT '06:00' as Expr1 UNION ALL
	SELECT '06:02' as Expr1 UNION ALL
	SELECT '06:04' as Expr1 UNION ALL
	SELECT '06:06' as Expr1 UNION ALL
	SELECT '06:08' as Expr1 UNION ALL
	SELECT '06:10' as Expr1 UNION ALL
	SELECT '06:12' as Expr1 UNION ALL
	SELECT '06:14' as Expr1 UNION ALL
	SELECT '06:16' as Expr1 UNION ALL
	SELECT '06:18' as Expr1 UNION ALL
	SELECT '06:20' as Expr1 UNION ALL
	SELECT '06:22' as Expr1 UNION ALL
	SELECT '06:24' as Expr1 UNION ALL
	SELECT '06:26' as Expr1 UNION ALL
	SELECT '06:28' as Expr1 UNION ALL
	SELECT '06:30' as Expr1 UNION ALL
	SELECT '06:32' as Expr1 UNION ALL
	SELECT '06:34' as Expr1 UNION ALL
	SELECT '06:36' as Expr1 UNION ALL
	SELECT '06:38' as Expr1 UNION ALL
	SELECT '06:40' as Expr1 UNION ALL
	SELECT '06:42' as Expr1 UNION ALL
	SELECT '06:44' as Expr1 UNION ALL
	SELECT '06:46' as Expr1 UNION ALL
	SELECT '06:48' as Expr1 UNION ALL
	SELECT '06:50' as Expr1 UNION ALL
	SELECT '06:52' as Expr1 UNION ALL
	SELECT '06:54' as Expr1 UNION ALL
	SELECT '06:56' as Expr1 UNION ALL
	SELECT '06:58' as Expr1 UNION ALL
	SELECT '07:00' as Expr1 UNION ALL
	SELECT '07:02' as Expr1 UNION ALL
	SELECT '07:04' as Expr1 UNION ALL
	SELECT '07:06' as Expr1 UNION ALL
	SELECT '07:08' as Expr1 UNION ALL
	SELECT '07:10' as Expr1 UNION ALL
	SELECT '07:12' as Expr1 UNION ALL
	SELECT '07:14' as Expr1 UNION ALL
	SELECT '07:16' as Expr1 UNION ALL
	SELECT '07:18' as Expr1 UNION ALL
	SELECT '07:20' as Expr1 UNION ALL
	SELECT '07:22' as Expr1 UNION ALL
	SELECT '07:24' as Expr1 UNION ALL
	SELECT '07:26' as Expr1 UNION ALL
	SELECT '07:28' as Expr1 UNION ALL
	SELECT '07:30' as Expr1 UNION ALL
	SELECT '07:32' as Expr1 UNION ALL
	SELECT '07:34' as Expr1 UNION ALL
	SELECT '07:36' as Expr1 UNION ALL
	SELECT '07:38' as Expr1 UNION ALL
	SELECT '07:40' as Expr1 UNION ALL
	SELECT '07:42' as Expr1 UNION ALL
	SELECT '07:44' as Expr1 UNION ALL
	SELECT '07:46' as Expr1 UNION ALL
	SELECT '07:48' as Expr1 UNION ALL
	SELECT '07:50' as Expr1 UNION ALL
	SELECT '07:52' as Expr1 UNION ALL
	SELECT '07:54' as Expr1 UNION ALL
	SELECT '07:56' as Expr1 UNION ALL
	SELECT '07:58' as Expr1 UNION ALL
	SELECT '08:00' as Expr1 UNION ALL
	SELECT '08:02' as Expr1 UNION ALL
	SELECT '08:04' as Expr1 UNION ALL
	SELECT '08:06' as Expr1 UNION ALL
	SELECT '08:08' as Expr1 UNION ALL
	SELECT '08:10' as Expr1 UNION ALL
	SELECT '08:12' as Expr1 UNION ALL
	SELECT '08:14' as Expr1 UNION ALL
	SELECT '08:16' as Expr1 UNION ALL
	SELECT '08:18' as Expr1 UNION ALL
	SELECT '08:20' as Expr1 UNION ALL
	SELECT '08:22' as Expr1 UNION ALL
	SELECT '08:24' as Expr1 UNION ALL
	SELECT '08:26' as Expr1 UNION ALL
	SELECT '08:28' as Expr1 UNION ALL
	SELECT '08:30' as Expr1 UNION ALL
	SELECT '08:32' as Expr1 UNION ALL
	SELECT '08:34' as Expr1 UNION ALL
	SELECT '08:36' as Expr1 UNION ALL
	SELECT '08:38' as Expr1 UNION ALL
	SELECT '08:40' as Expr1 UNION ALL
	SELECT '08:42' as Expr1 UNION ALL
	SELECT '08:44' as Expr1 UNION ALL
	SELECT '08:46' as Expr1 UNION ALL
	SELECT '08:48' as Expr1 UNION ALL
	SELECT '08:50' as Expr1 UNION ALL
	SELECT '08:52' as Expr1 UNION ALL
	SELECT '08:54' as Expr1 UNION ALL
	SELECT '08:56' as Expr1 UNION ALL
	SELECT '08:58' as Expr1 UNION ALL
	SELECT '09:00' as Expr1 UNION ALL
	SELECT '09:02' as Expr1 UNION ALL
	SELECT '09:04' as Expr1 UNION ALL
	SELECT '09:06' as Expr1 UNION ALL
	SELECT '09:08' as Expr1 UNION ALL
	SELECT '09:10' as Expr1 UNION ALL
	SELECT '09:12' as Expr1 UNION ALL
	SELECT '09:14' as Expr1 UNION ALL
	SELECT '09:16' as Expr1 UNION ALL
	SELECT '09:18' as Expr1 UNION ALL
	SELECT '09:20' as Expr1 UNION ALL
	SELECT '09:22' as Expr1 UNION ALL
	SELECT '09:24' as Expr1 UNION ALL
	SELECT '09:26' as Expr1 UNION ALL
	SELECT '09:28' as Expr1 UNION ALL
	SELECT '09:30' as Expr1 UNION ALL
	SELECT '09:32' as Expr1 UNION ALL
	SELECT '09:34' as Expr1 UNION ALL
	SELECT '09:36' as Expr1 UNION ALL
	SELECT '09:38' as Expr1 UNION ALL
	SELECT '09:40' as Expr1 UNION ALL
	SELECT '09:42' as Expr1 UNION ALL
	SELECT '09:44' as Expr1 UNION ALL
	SELECT '09:46' as Expr1 UNION ALL
	SELECT '09:48' as Expr1 UNION ALL
	SELECT '09:50' as Expr1 UNION ALL
	SELECT '09:52' as Expr1 UNION ALL
	SELECT '09:54' as Expr1 UNION ALL
	SELECT '09:56' as Expr1 UNION ALL
	SELECT '09:58' as Expr1 UNION ALL
	SELECT '10:00' as Expr1 UNION ALL
	SELECT '10:02' as Expr1 UNION ALL
	SELECT '10:04' as Expr1 UNION ALL
	SELECT '10:06' as Expr1 UNION ALL
	SELECT '10:08' as Expr1 UNION ALL
	SELECT '10:10' as Expr1 UNION ALL
	SELECT '10:12' as Expr1 UNION ALL
	SELECT '10:14' as Expr1 UNION ALL
	SELECT '10:16' as Expr1 UNION ALL
	SELECT '10:18' as Expr1 UNION ALL
	SELECT '10:20' as Expr1 UNION ALL
	SELECT '10:22' as Expr1 UNION ALL
	SELECT '10:24' as Expr1 UNION ALL
	SELECT '10:26' as Expr1 UNION ALL
	SELECT '10:28' as Expr1 UNION ALL
	SELECT '10:30' as Expr1 UNION ALL
	SELECT '10:32' as Expr1 UNION ALL
	SELECT '10:34' as Expr1 UNION ALL
	SELECT '10:36' as Expr1 UNION ALL
	SELECT '10:38' as Expr1 UNION ALL
	SELECT '10:40' as Expr1 UNION ALL
	SELECT '10:42' as Expr1 UNION ALL
	SELECT '10:44' as Expr1 UNION ALL
	SELECT '10:46' as Expr1 UNION ALL
	SELECT '10:48' as Expr1 UNION ALL
	SELECT '10:50' as Expr1 UNION ALL
	SELECT '10:52' as Expr1 UNION ALL
	SELECT '10:54' as Expr1 UNION ALL
	SELECT '10:56' as Expr1 UNION ALL
	SELECT '10:58' as Expr1 UNION ALL
	SELECT '11:00' as Expr1 UNION ALL
	SELECT '11:02' as Expr1 UNION ALL
	SELECT '11:04' as Expr1 UNION ALL
	SELECT '11:06' as Expr1 UNION ALL
	SELECT '11:08' as Expr1 UNION ALL
	SELECT '11:10' as Expr1 UNION ALL
	SELECT '11:12' as Expr1 UNION ALL
	SELECT '11:14' as Expr1 UNION ALL
	SELECT '11:16' as Expr1 UNION ALL
	SELECT '11:18' as Expr1 UNION ALL
	SELECT '11:20' as Expr1 UNION ALL
	SELECT '11:22' as Expr1 UNION ALL
	SELECT '11:24' as Expr1 UNION ALL
	SELECT '11:26' as Expr1 UNION ALL
	SELECT '11:28' as Expr1 UNION ALL
	SELECT '11:30' as Expr1 UNION ALL
	SELECT '11:32' as Expr1 UNION ALL
	SELECT '11:34' as Expr1 UNION ALL
	SELECT '11:36' as Expr1 UNION ALL
	SELECT '11:38' as Expr1 UNION ALL
	SELECT '11:40' as Expr1 UNION ALL
	SELECT '11:42' as Expr1 UNION ALL
	SELECT '11:44' as Expr1 UNION ALL
	SELECT '11:46' as Expr1 UNION ALL
	SELECT '11:48' as Expr1 UNION ALL
	SELECT '11:50' as Expr1 UNION ALL
	SELECT '11:52' as Expr1 UNION ALL
	SELECT '11:54' as Expr1 UNION ALL
	SELECT '11:56' as Expr1 UNION ALL
	SELECT '11:58' as Expr1 UNION ALL
	SELECT '12:00' as Expr1 UNION ALL
	SELECT '12:02' as Expr1 UNION ALL
	SELECT '12:04' as Expr1 UNION ALL
	SELECT '12:06' as Expr1 UNION ALL
	SELECT '12:08' as Expr1 UNION ALL
	SELECT '12:10' as Expr1 UNION ALL
	SELECT '12:12' as Expr1 UNION ALL
	SELECT '12:14' as Expr1 UNION ALL
	SELECT '12:16' as Expr1 UNION ALL
	SELECT '12:18' as Expr1 UNION ALL
	SELECT '12:20' as Expr1 UNION ALL
	SELECT '12:22' as Expr1 UNION ALL
	SELECT '12:24' as Expr1 UNION ALL
	SELECT '12:26' as Expr1 UNION ALL
	SELECT '12:28' as Expr1 UNION ALL
	SELECT '12:30' as Expr1 UNION ALL
	SELECT '12:32' as Expr1 UNION ALL
	SELECT '12:34' as Expr1 UNION ALL
	SELECT '12:36' as Expr1 UNION ALL
	SELECT '12:38' as Expr1 UNION ALL
	SELECT '12:40' as Expr1 UNION ALL
	SELECT '12:42' as Expr1 UNION ALL
	SELECT '12:44' as Expr1 UNION ALL
	SELECT '12:46' as Expr1 UNION ALL
	SELECT '12:48' as Expr1 UNION ALL
	SELECT '12:50' as Expr1 UNION ALL
	SELECT '12:52' as Expr1 UNION ALL
	SELECT '12:54' as Expr1 UNION ALL
	SELECT '12:56' as Expr1 UNION ALL
	SELECT '12:58' as Expr1 UNION ALL
	SELECT '13:00' as Expr1 UNION ALL
	SELECT '13:02' as Expr1 UNION ALL
	SELECT '13:04' as Expr1 UNION ALL
	SELECT '13:06' as Expr1 UNION ALL
	SELECT '13:08' as Expr1 UNION ALL
	SELECT '13:10' as Expr1 UNION ALL
	SELECT '13:12' as Expr1 UNION ALL
	SELECT '13:14' as Expr1 UNION ALL
	SELECT '13:16' as Expr1 UNION ALL
	SELECT '13:18' as Expr1 UNION ALL
	SELECT '13:20' as Expr1 UNION ALL
	SELECT '13:22' as Expr1 UNION ALL
	SELECT '13:24' as Expr1 UNION ALL
	SELECT '13:26' as Expr1 UNION ALL
	SELECT '13:28' as Expr1 UNION ALL
	SELECT '13:30' as Expr1 UNION ALL
	SELECT '13:32' as Expr1 UNION ALL
	SELECT '13:34' as Expr1 UNION ALL
	SELECT '13:36' as Expr1 UNION ALL
	SELECT '13:38' as Expr1 UNION ALL
	SELECT '13:40' as Expr1 UNION ALL
	SELECT '13:42' as Expr1 UNION ALL
	SELECT '13:44' as Expr1 UNION ALL
	SELECT '13:46' as Expr1 UNION ALL
	SELECT '13:48' as Expr1 UNION ALL
	SELECT '13:50' as Expr1 UNION ALL
	SELECT '13:52' as Expr1 UNION ALL
	SELECT '13:54' as Expr1 UNION ALL
	SELECT '13:56' as Expr1 UNION ALL
	SELECT '13:58' as Expr1 UNION ALL
	SELECT '14:00' as Expr1 UNION ALL
	SELECT '14:02' as Expr1 UNION ALL
	SELECT '14:04' as Expr1 UNION ALL
	SELECT '14:06' as Expr1 UNION ALL
	SELECT '14:08' as Expr1 UNION ALL
	SELECT '14:10' as Expr1 UNION ALL
	SELECT '14:12' as Expr1 UNION ALL
	SELECT '14:14' as Expr1 UNION ALL
	SELECT '14:16' as Expr1 UNION ALL
	SELECT '14:18' as Expr1 UNION ALL
	SELECT '14:20' as Expr1 UNION ALL
	SELECT '14:22' as Expr1 UNION ALL
	SELECT '14:24' as Expr1 UNION ALL
	SELECT '14:26' as Expr1 UNION ALL
	SELECT '14:28' as Expr1 UNION ALL
	SELECT '14:30' as Expr1 UNION ALL
	SELECT '14:32' as Expr1 UNION ALL
	SELECT '14:34' as Expr1 UNION ALL
	SELECT '14:36' as Expr1 UNION ALL
	SELECT '14:38' as Expr1 UNION ALL
	SELECT '14:40' as Expr1 UNION ALL
	SELECT '14:42' as Expr1 UNION ALL
	SELECT '14:44' as Expr1 UNION ALL
	SELECT '14:46' as Expr1 UNION ALL
	SELECT '14:48' as Expr1 UNION ALL
	SELECT '14:50' as Expr1 UNION ALL
	SELECT '14:52' as Expr1 UNION ALL
	SELECT '14:54' as Expr1 UNION ALL
	SELECT '14:56' as Expr1 UNION ALL
	SELECT '14:58' as Expr1 UNION ALL
	SELECT '15:00' as Expr1 UNION ALL
	SELECT '15:02' as Expr1 UNION ALL
	SELECT '15:04' as Expr1 UNION ALL
	SELECT '15:06' as Expr1 UNION ALL
	SELECT '15:08' as Expr1 UNION ALL
	SELECT '15:10' as Expr1 UNION ALL
	SELECT '15:12' as Expr1 UNION ALL
	SELECT '15:14' as Expr1 UNION ALL
	SELECT '15:16' as Expr1 UNION ALL
	SELECT '15:18' as Expr1 UNION ALL
	SELECT '15:20' as Expr1 UNION ALL
	SELECT '15:22' as Expr1 UNION ALL
	SELECT '15:24' as Expr1 UNION ALL
	SELECT '15:26' as Expr1 UNION ALL
	SELECT '15:28' as Expr1 UNION ALL
	SELECT '15:30' as Expr1 UNION ALL
	SELECT '15:32' as Expr1 UNION ALL
	SELECT '15:34' as Expr1 UNION ALL
	SELECT '15:36' as Expr1 UNION ALL
	SELECT '15:38' as Expr1 UNION ALL
	SELECT '15:40' as Expr1 UNION ALL
	SELECT '15:42' as Expr1 UNION ALL
	SELECT '15:44' as Expr1 UNION ALL
	SELECT '15:46' as Expr1 UNION ALL
	SELECT '15:48' as Expr1 UNION ALL
	SELECT '15:50' as Expr1 UNION ALL
	SELECT '15:52' as Expr1 UNION ALL
	SELECT '15:54' as Expr1 UNION ALL
	SELECT '15:56' as Expr1 UNION ALL
	SELECT '15:58' as Expr1 UNION ALL
	SELECT '16:00' as Expr1 UNION ALL
	SELECT '16:02' as Expr1 UNION ALL
	SELECT '16:04' as Expr1 UNION ALL
	SELECT '16:06' as Expr1 UNION ALL
	SELECT '16:08' as Expr1 UNION ALL
	SELECT '16:10' as Expr1 UNION ALL
	SELECT '16:12' as Expr1 UNION ALL
	SELECT '16:14' as Expr1 UNION ALL
	SELECT '16:16' as Expr1 UNION ALL
	SELECT '16:18' as Expr1 UNION ALL
	SELECT '16:20' as Expr1 UNION ALL
	SELECT '16:22' as Expr1 UNION ALL
	SELECT '16:24' as Expr1 UNION ALL
	SELECT '16:26' as Expr1 UNION ALL
	SELECT '16:28' as Expr1 UNION ALL
	SELECT '16:30' as Expr1 UNION ALL
	SELECT '16:32' as Expr1 UNION ALL
	SELECT '16:34' as Expr1 UNION ALL
	SELECT '16:36' as Expr1 UNION ALL
	SELECT '16:38' as Expr1 UNION ALL
	SELECT '16:40' as Expr1 UNION ALL
	SELECT '16:42' as Expr1 UNION ALL
	SELECT '16:44' as Expr1 UNION ALL
	SELECT '16:46' as Expr1 UNION ALL
	SELECT '16:48' as Expr1 UNION ALL
	SELECT '16:50' as Expr1 UNION ALL
	SELECT '16:52' as Expr1 UNION ALL
	SELECT '16:54' as Expr1 UNION ALL
	SELECT '16:56' as Expr1 UNION ALL
	SELECT '16:58' as Expr1 UNION ALL
	SELECT '17:00' as Expr1 UNION ALL
	SELECT '17:02' as Expr1 UNION ALL
	SELECT '17:04' as Expr1 UNION ALL
	SELECT '17:06' as Expr1 UNION ALL
	SELECT '17:08' as Expr1 UNION ALL
	SELECT '17:10' as Expr1 UNION ALL
	SELECT '17:12' as Expr1 UNION ALL
	SELECT '17:14' as Expr1 UNION ALL
	SELECT '17:16' as Expr1 UNION ALL
	SELECT '17:18' as Expr1 UNION ALL
	SELECT '17:20' as Expr1 UNION ALL
	SELECT '17:22' as Expr1 UNION ALL
	SELECT '17:24' as Expr1 UNION ALL
	SELECT '17:26' as Expr1 UNION ALL
	SELECT '17:28' as Expr1 UNION ALL
	SELECT '17:30' as Expr1 UNION ALL
	SELECT '17:32' as Expr1 UNION ALL
	SELECT '17:34' as Expr1 UNION ALL
	SELECT '17:36' as Expr1 UNION ALL
	SELECT '17:38' as Expr1 UNION ALL
	SELECT '17:40' as Expr1 UNION ALL
	SELECT '17:42' as Expr1 UNION ALL
	SELECT '17:44' as Expr1 UNION ALL
	SELECT '17:46' as Expr1 UNION ALL
	SELECT '17:48' as Expr1 UNION ALL
	SELECT '17:50' as Expr1 UNION ALL
	SELECT '17:52' as Expr1 UNION ALL
	SELECT '17:54' as Expr1 UNION ALL
	SELECT '17:56' as Expr1 UNION ALL
	SELECT '17:58' as Expr1 UNION ALL
	SELECT '18:00' as Expr1 UNION ALL
	SELECT '18:02' as Expr1 UNION ALL
	SELECT '18:04' as Expr1 UNION ALL
	SELECT '18:06' as Expr1 UNION ALL
	SELECT '18:08' as Expr1 UNION ALL
	SELECT '18:10' as Expr1 UNION ALL
	SELECT '18:12' as Expr1 UNION ALL
	SELECT '18:14' as Expr1 UNION ALL
	SELECT '18:16' as Expr1 UNION ALL
	SELECT '18:18' as Expr1 UNION ALL
	SELECT '18:20' as Expr1 UNION ALL
	SELECT '18:22' as Expr1 UNION ALL
	SELECT '18:24' as Expr1 UNION ALL
	SELECT '18:26' as Expr1 UNION ALL
	SELECT '18:28' as Expr1 UNION ALL
	SELECT '18:30' as Expr1 UNION ALL
	SELECT '18:32' as Expr1 UNION ALL
	SELECT '18:34' as Expr1 UNION ALL
	SELECT '18:36' as Expr1 UNION ALL
	SELECT '18:38' as Expr1 UNION ALL
	SELECT '18:40' as Expr1 UNION ALL
	SELECT '18:42' as Expr1 UNION ALL
	SELECT '18:44' as Expr1 UNION ALL
	SELECT '18:46' as Expr1 UNION ALL
	SELECT '18:48' as Expr1 UNION ALL
	SELECT '18:50' as Expr1 UNION ALL
	SELECT '18:52' as Expr1 UNION ALL
	SELECT '18:54' as Expr1 UNION ALL
	SELECT '18:56' as Expr1 UNION ALL
	SELECT '18:58' as Expr1 UNION ALL
	SELECT '19:00' as Expr1 UNION ALL
	SELECT '19:02' as Expr1 UNION ALL
	SELECT '19:04' as Expr1 UNION ALL
	SELECT '19:06' as Expr1 UNION ALL
	SELECT '19:08' as Expr1 UNION ALL
	SELECT '19:10' as Expr1 UNION ALL
	SELECT '19:12' as Expr1 UNION ALL
	SELECT '19:14' as Expr1 UNION ALL
	SELECT '19:16' as Expr1 UNION ALL
	SELECT '19:18' as Expr1 UNION ALL
	SELECT '19:20' as Expr1 UNION ALL
	SELECT '19:22' as Expr1 UNION ALL
	SELECT '19:24' as Expr1 UNION ALL
	SELECT '19:26' as Expr1 UNION ALL
	SELECT '19:28' as Expr1 UNION ALL
	SELECT '19:30' as Expr1 UNION ALL
	SELECT '19:32' as Expr1 UNION ALL
	SELECT '19:34' as Expr1 UNION ALL
	SELECT '19:36' as Expr1 UNION ALL
	SELECT '19:38' as Expr1 UNION ALL
	SELECT '19:40' as Expr1 UNION ALL
	SELECT '19:42' as Expr1 UNION ALL
	SELECT '19:44' as Expr1 UNION ALL
	SELECT '19:46' as Expr1 UNION ALL
	SELECT '19:48' as Expr1 UNION ALL
	SELECT '19:50' as Expr1 UNION ALL
	SELECT '19:52' as Expr1 UNION ALL
	SELECT '19:54' as Expr1 UNION ALL
	SELECT '19:56' as Expr1 UNION ALL
	SELECT '19:58' as Expr1 UNION ALL
	SELECT '20:00' as Expr1 UNION ALL
	SELECT '20:02' as Expr1 UNION ALL
	SELECT '20:04' as Expr1 UNION ALL
	SELECT '20:06' as Expr1 UNION ALL
	SELECT '20:08' as Expr1 UNION ALL
	SELECT '20:10' as Expr1 UNION ALL
	SELECT '20:12' as Expr1 UNION ALL
	SELECT '20:14' as Expr1 UNION ALL
	SELECT '20:16' as Expr1 UNION ALL
	SELECT '20:18' as Expr1 UNION ALL
	SELECT '20:20' as Expr1 UNION ALL
	SELECT '20:22' as Expr1 UNION ALL
	SELECT '20:24' as Expr1 UNION ALL
	SELECT '20:26' as Expr1 UNION ALL
	SELECT '20:28' as Expr1 UNION ALL
	SELECT '20:30' as Expr1 UNION ALL
	SELECT '20:32' as Expr1 UNION ALL
	SELECT '20:34' as Expr1 UNION ALL
	SELECT '20:36' as Expr1 UNION ALL
	SELECT '20:38' as Expr1 UNION ALL
	SELECT '20:40' as Expr1 UNION ALL
	SELECT '20:42' as Expr1 UNION ALL
	SELECT '20:44' as Expr1 UNION ALL
	SELECT '20:46' as Expr1 UNION ALL
	SELECT '20:48' as Expr1 UNION ALL
	SELECT '20:50' as Expr1 UNION ALL
	SELECT '20:52' as Expr1 UNION ALL
	SELECT '20:54' as Expr1 UNION ALL
	SELECT '20:56' as Expr1 UNION ALL
	SELECT '20:58' as Expr1 UNION ALL
	SELECT '21:00' as Expr1 UNION ALL
	SELECT '21:02' as Expr1 UNION ALL
	SELECT '21:04' as Expr1 UNION ALL
	SELECT '21:06' as Expr1 UNION ALL
	SELECT '21:08' as Expr1 UNION ALL
	SELECT '21:10' as Expr1 UNION ALL
	SELECT '21:12' as Expr1 UNION ALL
	SELECT '21:14' as Expr1 UNION ALL
	SELECT '21:16' as Expr1 UNION ALL
	SELECT '21:18' as Expr1 UNION ALL
	SELECT '21:20' as Expr1 UNION ALL
	SELECT '21:22' as Expr1 UNION ALL
	SELECT '21:24' as Expr1 UNION ALL
	SELECT '21:26' as Expr1 UNION ALL
	SELECT '21:28' as Expr1 UNION ALL
	SELECT '21:30' as Expr1 UNION ALL
	SELECT '21:32' as Expr1 UNION ALL
	SELECT '21:34' as Expr1 UNION ALL
	SELECT '21:36' as Expr1 UNION ALL
	SELECT '21:38' as Expr1 UNION ALL
	SELECT '21:40' as Expr1 UNION ALL
	SELECT '21:42' as Expr1 UNION ALL
	SELECT '21:44' as Expr1 UNION ALL
	SELECT '21:46' as Expr1 UNION ALL
	SELECT '21:48' as Expr1 UNION ALL
	SELECT '21:50' as Expr1 UNION ALL
	SELECT '21:52' as Expr1 UNION ALL
	SELECT '21:54' as Expr1 UNION ALL
	SELECT '21:56' as Expr1 UNION ALL
	SELECT '21:58' as Expr1 UNION ALL
	SELECT '22:00' as Expr1 UNION ALL
	SELECT '22:02' as Expr1 UNION ALL
	SELECT '22:04' as Expr1 UNION ALL
	SELECT '22:06' as Expr1 UNION ALL
	SELECT '22:08' as Expr1 UNION ALL
	SELECT '22:10' as Expr1 UNION ALL
	SELECT '22:12' as Expr1 UNION ALL
	SELECT '22:14' as Expr1 UNION ALL
	SELECT '22:16' as Expr1 UNION ALL
	SELECT '22:18' as Expr1 UNION ALL
	SELECT '22:20' as Expr1 UNION ALL
	SELECT '22:22' as Expr1 UNION ALL
	SELECT '22:24' as Expr1 UNION ALL
	SELECT '22:26' as Expr1 UNION ALL
	SELECT '22:28' as Expr1 UNION ALL
	SELECT '22:30' as Expr1 UNION ALL
	SELECT '22:32' as Expr1 UNION ALL
	SELECT '22:34' as Expr1 UNION ALL
	SELECT '22:36' as Expr1 UNION ALL
	SELECT '22:38' as Expr1 UNION ALL
	SELECT '22:40' as Expr1 UNION ALL
	SELECT '22:42' as Expr1 UNION ALL
	SELECT '22:44' as Expr1 UNION ALL
	SELECT '22:46' as Expr1 UNION ALL
	SELECT '22:48' as Expr1 UNION ALL
	SELECT '22:50' as Expr1 UNION ALL
	SELECT '22:52' as Expr1 UNION ALL
	SELECT '22:54' as Expr1 UNION ALL
	SELECT '22:56' as Expr1 UNION ALL
	SELECT '22:58' as Expr1 UNION ALL
	SELECT '23:00' as Expr1 UNION ALL
	SELECT '23:02' as Expr1 UNION ALL
	SELECT '23:04' as Expr1 UNION ALL
	SELECT '23:06' as Expr1 UNION ALL
	SELECT '23:08' as Expr1 UNION ALL
	SELECT '23:10' as Expr1 UNION ALL
	SELECT '23:12' as Expr1 UNION ALL
	SELECT '23:14' as Expr1 UNION ALL
	SELECT '23:16' as Expr1 UNION ALL
	SELECT '23:18' as Expr1 UNION ALL
	SELECT '23:20' as Expr1 UNION ALL
	SELECT '23:22' as Expr1 UNION ALL
	SELECT '23:24' as Expr1 UNION ALL
	SELECT '23:26' as Expr1 UNION ALL
	SELECT '23:28' as Expr1 UNION ALL
	SELECT '23:30' as Expr1 UNION ALL
	SELECT '23:32' as Expr1 UNION ALL
	SELECT '23:34' as Expr1 UNION ALL
	SELECT '23:36' as Expr1 UNION ALL
	SELECT '23:38' as Expr1 UNION ALL
	SELECT '23:40' as Expr1 UNION ALL
	SELECT '23:42' as Expr1 UNION ALL
	SELECT '23:44' as Expr1 UNION ALL
	SELECT '23:46' as Expr1 UNION ALL
	SELECT '23:48' as Expr1 UNION ALL
	SELECT '23:50' as Expr1 UNION ALL
	SELECT '23:52' as Expr1 UNION ALL
	SELECT '23:54' as Expr1 UNION ALL
	SELECT '23:56' as Expr1 UNION ALL
	SELECT '23:58' as Expr1
	)  LK_HORAS
	ON (LK_HORAS.Expr1=case when substring(a.hour,1,2)='24' then '00'+substring(a.hour,3,3) else a.hour end)
  )  Sales_hour_physical_cannel_prev_week
GROUP BY
  Sales_hour_physical_cannel_prev_week.BD,
  Sales_hour_physical_cannel_prev_week.hour,
  Sales_hour_physical_cannel_prev_week.channel_lvl1,
  Sales_hour_physical_cannel_prev_week.channelLvl2,
  Sales_hour_physical_cannel_prev_week.Expr1,
  left(Sales_hour_physical_cannel_prev_week.Expr1,2))C2

ORDER BY HORA
