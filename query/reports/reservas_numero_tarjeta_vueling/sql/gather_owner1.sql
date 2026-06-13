SELECT
  Table__9.OWNER,
  Table__9.RecordLocator,
  Table__9.PaymentAmount,
  Table__9.CurrencyCode,
  Table__9.BookingDate,
  Table__9.Name,
  Table__9.ReceivedBy,
  Table__9.AgentName,
  Table__9.EmailAddress,
  Table__9.salida,
  Table__9.llegada

FROM
  (
     SELECT
  --Table__9.AccountNumberID,
  Table__9.BookingID,
 -- Table__9.CODIGO,
  Table__9.OWNER,
  Table__9.RecordLocator,
  Table__9.salida,
  getdate() as FechaActual,
  Table__9.llegada,
  Table__9.PaymentAmount,
  Table__9.CurrencyCode,
  Table__9.Name,
  Table__9.EmailAddress,
  Table__9.AgentName,
  Table__9.BookingDate,
  Table__9.ReceivedBy
FROM
  (
  SELECT  a.EmailAddress, a.Name,a.AgentName,a.BookingID,a.ReceivedBy,a.BookingDate
  --,a.AccountNumberID,a.CODIGO
  ,a.OWNER, a.RecordLocator,a.salida,
case when a.salida=a.llegada then null else a.llegada end as llegada , MIN(a.PaymentAmount) AS  PaymentAmount, a.CurrencyCode

FROM (
select max(con.EmailAddress) EmailAddress, max(con.LastName+' '+con.FirstName) as name,agent.AgentName,a.BookingID,a.ReceivedBy
,a.BookingDate
--,c.AccountNumberID,bines.CODIGO
,BINES.OWNER,
a.RecordLocator,MIN(seg.DepartureDate) over (partition by a.recordlocator) as salida,MAX(seg.DepartureDate) over (partition by a.recordlocator) as llegada
, SUM(c.PaymentAmounT) over (partition by  a.BookingID+seg.SEGMENTNUMBER+leg.JourneyNumber) as PaymentAmount, c.currencycode
from dbo.Booking a
inner join BookingPassenger b on a.BookingID=B.BookingID
 INNER JOIN  dbo.Payment c  ON c.ReferenceID=B.BookingId
 inner join dbo.PassengerJourneyLeg leg on leg.PassengerID=b.PassengerID inner join
	dbo.PassengerJourneySegment seg on seg.PassengerID=leg.PassengerID and seg.SegmentId = leg.SegmentId
INNER JOIN (

select '3178712' as accountId, '************4273' as CODIGO, '{0}' as OWNER UNION ALL
	select '3178711' as accountId, '************4273' as CODIGO, '{0}' as OWNER UNION ALL
	select '3667873' as accountId, '************3756' as CODIGO, '{0}' as OWNER UNION ALL
	select '9631898' as accountId, '************3603' as CODIGO, '{0}' as OWNER UNION ALL
	select '7948769' as accountId, '************4273' as CODIGO, '{0}' as OWNER UNION ALL
	--select '5552804' as accountId, '************5531' as CODIGO, '{0}' as OWNER UNION ALL
	select '11311880' as accountId, '************9533' as CODIGO, '{0}' as OWNER UNION ALL
	select '2861870' as accountId, '************5566' as CODIGO, '{1}' as OWNER UNION ALL
	select '2860762' as accountId, '************5402' as CODIGO, '{1}' as OWNER UNION ALL
	select '2503910' as accountId, '************4864' as CODIGO, '{1}' as OWNER UNION ALL
	/*select '8180363' as accountId, '************6013' as CODIGO, '{2}' as OWNER UNION ALL
	--select '4861297' as accountId, '************9011' as CODIGO, '{2}' as OWNER UNION ALL
	select '11205660' as accountId, '************9011' as CODIGO, '{2}' as OWNER UNION ALL
	select '11074219' as accountId, '************1014' as CODIGO, '{2}' as OWNER UNION ALL
	-- nous {2}
	select '3667873' as accountId, '************1004' as CODIGO, '{2}' as OWNER UNION ALL
	select '9631898' as accountId, '************0361' as CODIGO, '{2}' as OWNER UNION ALL
	select '16745617' as accountId, '************6021' as CODIGO, '{2}' as OWNER UNION ALL
	select '16760976' as accountId, '************2019' as CODIGO, '{2}' as OWNER UNION ALL
	select '16760996' as accountId, '************9029' as CODIGO, '{2}' as OWNER UNION ALL
	select '16761013' as accountId, '************3034' as CODIGO, '{2}' as OWNER UNION ALL
	select '5552804' as accountId, '************8014' as CODIGO, '{2}' as OWNER UNION ALL
	-- FIN SAMUEL
    */
	select '6388062' as accountId, '************1354' as CODIGO, '{3}' as OWNER UNION ALL
	select '9578395' as accountId, '************1007' as CODIGO, '{2}' as OWNER UNION ALL
	select '3667873' as accountId, '************1004' as CODIGO, '{0}' as OWNER UNION ALL
	select '9631898' as accountId, '************0361' as CODIGO, '{0}' as OWNER UNION ALL
	select '16745617' as accountId, '************6021' as CODIGO, '{0}' as OWNER UNION ALL
	select '16760976' as accountId, '************2019' as CODIGO, '{0}' as OWNER UNION ALL
	--select '16760996' as accountId, '************9029' as CODIGO, '{0}' as OWNER UNION ALL
	-- nous {0}
	select '17280940' as accountId, '************0286' as CODIGO, '{0}' as OWNER UNION ALL
	select '17006690' as accountId, '************3016' as CODIGO, '{0}' as OWNER UNION ALL
	select '16785021' as accountId, '************6016' as CODIGO, '{0}' as OWNER UNION ALL
	select '17098104' as accountId, '************9017' as CODIGO, '{0}' as OWNER UNION ALL
	select '17098572' as accountId, '************7014' as CODIGO, '{0}' as OWNER UNION ALL
	select '7948769' as accountId, '************2057' as CODIGO, '{0}' as OWNER UNION ALL
	--select '16760996' as accountId, '************8014' as CODIGO, '{0}' as OWNER UNION ALL
	select '18323448' as accountId, '************1719' as CODIGO, '{0}' as OWNER UNION ALL
	  --5531 0800 8793 8014 esta targeta cambiar accountname a {2} -> {0}
	  --select '16761013' as accountId, '************3034' as CODIGO, '{0}' as OWNER
	select '49479934' as accountId, '************9371' as CODIGO, '{0}' as OWNER
	-- FIN JAVIER

 ) AS BINES ON
BINES.accountID =C.AccountNumberID
left join dbo.Agent agent on agent.AgentID=a.CreatedAgentID
 left JOIN dbo.BookingContact con on con.BookingID=a.BookingID
where a.BookingDate >='2013-01-01'
and a.Status in (1,2,3) AND
leg.PassengerID is not null and
c.Status <>4
--and a.RecordLocator ='V5BI2L'
group by  agent.AgentName,a.BookingID,a.ReceivedBy,a.BookingDate, c.currencycode
--,C.AccountNumberID,BINES.CODIGO
,BINES.OWNER,seg.DepartureDate, a.RecordLocator, a.BookingID+seg.SEGMENTNUMBER+leg.JourneyNumber,c.PaymentAmounT
having SUM(c.PaymentAmounT)<> 0 ) A
where A.PaymentAmount<>0
GROUP BY  a.EmailAddress, a.Name,a.AgentName,a.BookingID,a.ReceivedBy,a.BookingDate, a.currencycode
--,a.AccountNumberID,a.CODIGO
,a.OWNER, a.RecordLocator,a.salida,case when a.salida=a.llegada then null else a.llegada end
 )  Table__9
  )  Table__9

where   Table__9.OWNER = '{0}'