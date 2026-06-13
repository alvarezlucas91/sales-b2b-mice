with aux as
(
select
    il.departuredate,
    il.FlightNumber,
    il.departurestation,
    il.arrivalstation,
    [dbo].[DecryptSSR](pjssr.SSRCode,pjssr.PassengerID,pjssr.SegmentID,pjssr.LegNumber) SSR
from Vueling_Navitaire.ODS_DATABASE.PassengerJourneySegment pjs with(nolock)
    inner join Vueling_Navitaire.ODS_DATABASE.[PassengerJourneySSR_Encrypted] pjssr with (nolock)
        on pjssr.SegmentID=pjs.segmentID and pjssr.passengerid=pjs.passengerid
            and [dbo].[DecryptSSR](pjssr.SSRCode,pjssr.PassengerID,pjssr.SegmentID,pjssr.LegNumber) in ('WCHR','WCHC','WCHS','BLND','DPNA') --PMR según el gobierno
    inner join Vueling_Navitaire.ODS_DATABASE.PassengerJourneyLeg pjl with(nolock)
        on pjs.PassengerID=pjl.PassengerID and pjs.SegmentID=pjl.SegmentID
    inner join Vueling_Navitaire.ODS_DATABASE.InventoryLeg il with(nolock)
        on pjl.InventoryLegID=il.InventoryLegID
where
    il.DepartureDate between '{0}' and '{1}'
	and (il.departurestation ='VLC' or il.arrivalstation ='VLC')
)
select
    aux.departuredate,
    aux.FlightNumber,
    aux.departurestation,
    aux.arrivalstation,
	sum(case WHEN ssr = 'BLND' THEN 1 ELSE 0 end)as 'BLND',
	sum(case WHEN ssr = 'DPNA' THEN 1 ELSE 0 end)as 'DPNA',
	sum(case WHEN ssr = 'WCHC' THEN 1 ELSE 0 end)as 'WCHC',
	sum(case WHEN ssr = 'WCHR' THEN 1 ELSE 0 end)as 'WCHR',
	sum(case WHEN ssr = 'WCHS' THEN 1 ELSE 0 end)as 'WCHS'
from aux
group by
    aux.departuredate,
    aux.FlightNumber,
    aux.departurestation,
    aux.arrivalstation