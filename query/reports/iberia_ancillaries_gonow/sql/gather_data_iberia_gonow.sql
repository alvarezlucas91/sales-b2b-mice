
SELECT
	b.RecordLocator
	,fc.FeeNumber
	,fc.ChargeCode
	,CAST(MAX(fc.createdUTC) AS DATE) AS TransactionDateUTC
	,CAST(MAX(fc.createdUTC) AS TIME(0)) TransactionHourUTC
	,MAX(fc.ChargeDetail) AS ChargeDetail
	,SUM((CASE WHEN ChargeType = 1 THEN -1 ELSE 1 END)*fc.ChargeAmount) AS ChargeAmount
	, MAX(fc.CurrencyCode) AS CurrencyCode
	,bp.FirstName
	,bp.LastName
	,a.AgentName
	,LEFT(a.AgentName,3) AS Airport
	, CAST(STD AS SMALLDATETIME) AS STD
	, FlightNumber
	, l.DepartureStation
	, l.ArrivalStation
FROM
	rez.passengerfeecharge fc WITH(NOLOCK)
	inner join rez.Agent a WITH(NOLOCK) ON a.AgentID = fc.CreatedUserID
	inner join rez.BookingPassenger bp WITH(NOLOCK) ON bp.PassengerID = fc.PassengerID
	inner join rez.booking b WITH(NOLOCK) ON b.bookingid = bp.bookingid
	inner join rez.PassengerFee f WITH(NOLOCK) ON f.PassengerID = fc.PassengerID and f.FeeNumber = fc.FeeNumber
	left join InventoryLeg l WITH(NOLOCK) ON l.InventoryLegID = f.InventoryLegID
	WHERE
		a.AgentName like '[A-Z][A-Z][A-Z][AS][0-9][0-9][0-9][0-9]'
		and fc.chargecode NOT IN ('IVAA','IVA','SPL', 'PFSC')
		and fc.chargeamount > 0
		and LEFT(a.AgentName,3) IN ('AGP','ALC','BCN','BIO','IBZ','LPA','MAH','PMI','TFN')
		and  CONVERT(VARCHAR(6), CAST(fc.createdUTC AS DATE), 112) = CAST(YEAR(DATEADD(MONTH, -1, GETDATE())) AS VARCHAR(4))
			+ RIGHT('0' + CAST(MONTH(DATEADD(MONTH, -1, GETDATE())) AS VARCHAR(2)), 2)
		and exists(SELECT 1 FROM Payment p WHERE p.referenceID = bp.BookingID and p.CreatedAgentCode = a.AgentName and p.CreatedAgentCode like '[A-Z][A-Z][A-Z][AS][0-9][0-9][0-9][0-9]')
GROUP BY
	b.recordlocator
	,fc.feenumber
	,fc.chargecode
	,bp.FirstName
	,bp.LastName
	,a.AgentName
	,LEFT(a.AgentName,3)
	,CAST(STD AS SMALLDATETIME)
	,FlightNumber
	,l.DepartureStation
	,l.ArrivalStation
HAVING
	SUM((CASE WHEN ChargeType = 1 THEN -1. ELSE 1. END)*fc.chargeamount) > 0