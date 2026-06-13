with PNR as -- PNR afectados por VYRefundVoucher
(
select distinct
	B.bookingid,
	B.Recordlocator as PNR,
	P.ApprovalDate as [TG Payment Date]
from [Vueling_Navitaire].[dbo].[Booking] B
	inner join [Vueling_Navitaire].[dbo].[BookingHistory] BH on BH.BookingID = B.BookingID
	inner join [Vueling_Navitaire].[dbo].[Payment] P on B.bookingid = P.referenceID
where P.PaymentMethodCode ='TG'
	and P.CreatedAgentCode = 'plusgrade'
	and BH.CreatedAgentCode = 'VYRefundVoucher'
), seat as
(
select distinct
	B.Recordlocator as PNR,
	B.CreatedAgentCode as [Original Agent],
	cast(B.bookingdate as date) as [Booking date],
	right(left(BH.Detail, 4), 3) as [Origin],
	right(left(BH.Detail, 8), 3) as [Destination],
	DATEADD(ms, -DATEPART(ms, BH.CreatedDate), BH.CreatedDate) as [Plusgrade date],
	right(left(BH.Detail, 17), 3) as [Seat Assigned]
from
	Vueling_Navitaire.dbo.booking B
		inner join Vueling_Navitaire.dbo.BookingHistory BH on BH.bookingid = B.bookingid
where year(B.bookingdate) = 2024
	and BH.CreatedAgentCode = 'Plusgrade'
	and BH.HistoryCode = 'AS'
)
select distinct
	PNR.PNR,
	PNR.[TG Payment Date],
	PJS.DepartureDate as [Flight Date],
	PJS.DepartureStation+PJS.ArrivalStation as [Impacted Segment],
	SEAT.[Seat Assigned] as [Seat Number],
	max(BP.pax_nbr) as [Number of Passengers],
	P.PaymentAmount as [Refund Amount]
from PNR
	inner join SEAT on SEAT.PNR = PNR.PNR
	left join [Vueling_Navitaire].[dbo].[Payment] P on PNR.bookingid = P.referenceID and CreatedAgentCode = 'VYRefundVoucher'
	inner join [Vueling_Navitaire].[dbo].[BookingPassenger] BP on BP.bookingid = PNR.bookingid
	inner join [Vueling_Navitaire].[dbo].[PassengerJourneySegment] PJS on BP.passengerid = PJS.passengerID and PJS.DepartureStation = trim('	' FROM SEAT.[Origin])
group by
	PNR.PNR,
	PNR.[TG Payment Date],
	PJS.DepartureDate,
	PJS.DepartureStation+PJS.ArrivalStation,
	SEAT.[Seat Assigned],
	P.PaymentAmount
;