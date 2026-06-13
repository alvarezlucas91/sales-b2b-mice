select distinct
	b.RecordLocator,
	b.BookingDate,
	bp.FirstName,
	bp.LastName,
	pf.Note,
	pf.Status,
	pf.CreatedDate,
	pf.ModifiedDate,
	pf.CreatedAgentID,
	a.AgentName
from vueling_navitaire.dbo.booking b with(nolock)
	inner join vueling_navitaire.dbo.bookingpassenger bp with(nolock) ON b.bookingid = bp.bookingid
    inner join vueling_navitaire.dbo.passengerjourneysegment pjs with(nolock) ON bp.passengerid = pjs.passengerid
    inner join vueling_navitaire.dbo.passengerJourneyLeg pjl with(nolock) ON pjs.passengerid = pjl.passengerid and pjs.SegmentID = pjl.SegmentID
	inner join vueling_navitaire.dbo.passengerFee pf with(nolock) ON bp.passengerid = pf.passengerid
    inner join vueling_navitaire.dbo.Agent a with(nolock) ON a.AgentID = pf.CreatedAgentID
where 1=1
  and pf.Status in ('HP')
  and pf.CreatedDate < getdate()
  and b.paidStatus = 1
  and pjl.LiftStatus in (0,1)
  and pf.FeeCode IN ('INPL','INST', 'INBG');