select
	soi.flightnumber,
	so.departuredate,
	soi.departure,
	soi.stdlt as departure_time,
	soi.arrival,
	soi.stalt as arrival_time,
	so.totalofpax ,
	p.cd_pnr,
	so.name,
	so.stagename,
	so.groupname,
	sc.firstname,
	sc.lastname,
	sc.email,
	so.createddate,
	so.type
FROM sfdc.sfdc_opportunity so
join sfdc.sfdc_opportunitylineitem soi on so.id_sfdc =soi.opportunityid
join sfdc.sfdc_contact sc on sc.id_account = so.accountid
left join sfdc.sfdc_pnr p ON p.cd_pnr  = so.depositpnr
where so.type = 'SportsCompetition'
and so.departuredate  BETWEEN DATEADD(DAY, -1, GETDATE()) AND DATEADD(DAY, 46, GETDATE())

