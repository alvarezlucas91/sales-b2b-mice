with noBoarded as
(
select
       YEAR(il.DepartureDate) as Year_Flight_Date,
  MONTH(il.DepartureDate) as Month_Flight_Date,
  COUNT(distinct bp.PassengerID) as Num_Pax,
  COUNT(distinct pjs.SegmentID) as Num_Segments
from
	rez.booking b WITH (NOLOCK)
		INNER JOIN rez.BookingPassenger bp on bp.BookingID = b.BookingID
		INNER JOIN rez.PassengerJourneySegment pjs WITH (NOLOCK) on bp.PassengerID = pjs.PassengerID
		INNER JOIN rez.PassengerJourneyLeg pjl WITH (NOLOCK) on pjs.PassengerID = pjl.PassengerID  and pjs.SegmentID = pjl.SegmentID
		INNER JOIN rez.InventoryLeg il WITH (NOLOCK) on pjl.InventoryLegID = il.inventoryLegID
where
	1 = 1
	and pjl.UnitDesignator not in ('1A','1B','1C','1D','1E','1F','2A','2B','2C','2D','2E','2F','3A','3B','3C','3D','3E','3F','4A','4B','4C','4D','4E','4F')
	and  exists (  select 1
                    from rez.PassengerJourneySSr  pjssr WITH (NOLOCK)
                    where pjs.PassengerId = pjssr.PassengerID
                    and pjs.SegmentID = pjssr.SegmentID
                    and SSRCode = 'NGCB'
                    and  pjssr.CreatedUserId in ('5440708', '10814700'))
group by YEAR(il.DepartureDate) ,MONTH(il.DepartureDate)
), Boarded as
(
select
       YEAR(il.DepartureDate) as Year_Flight_Date,
  MONTH(il.DepartureDate) as Month_Flight_Date,
  COUNT(distinct bp.PassengerID) as Num_Pax_Boarded,
  COUNT(distinct pjs.SegmentID) as Num_Segments_Boarded
from
	rez.booking b WITH (NOLOCK)
		INNER JOIN rez.BookingPassenger bp on bp.BookingID = b.BookingID
		INNER JOIN rez.PassengerJourneySegment pjs WITH (NOLOCK) on bp.PassengerID = pjs.PassengerID
		INNER JOIN rez.PassengerJourneyLeg pjl WITH (NOLOCK) on pjs.PassengerID = pjl.PassengerID  and pjs.SegmentID = pjl.SegmentID
		INNER JOIN rez.InventoryLeg il WITH (NOLOCK) on pjl.InventoryLegID = il.inventoryLegID
where
	1 = 1
	and PJS.ChangeReasonCode != ''
	and PJL.LiftStatus = 2
	and pjl.UnitDesignator not in ('1A','1B','1C','1D','1E','1F','2A','2B','2C','2D','2E','2F','3A','3B','3C','3D','3E','3F','4A','4B','4C','4D','4E','4F')
	and  exists (  select 1
                    from rez.PassengerJourneySSr  pjssr WITH (NOLOCK)
                    where pjs.PassengerId = pjssr.PassengerID
                    and pjs.SegmentID = pjssr.SegmentID
                    and SSRCode = 'NGCB'
                    and  pjssr.CreatedUserId in ('5440708', '10814700'))
group by YEAR(il.DepartureDate) ,MONTH(il.DepartureDate)
)
select
	NB.Year_Flight_Date,
	NB.Month_Flight_Date,
	Num_Pax as Total_Pax,
	Num_Segments as Total_Segments,
	Num_Pax_Boarded as Total_Pax_Boarded_Disruption,
	Num_Segments_Boarded as Total_Segment_Boarded_Disruption
from
	noBoarded nb
		inner join Boarded B on B.Year_Flight_Date = NB.Year_Flight_Date and B.Month_Flight_Date = NB.Month_Flight_Date
order by 1, 2;