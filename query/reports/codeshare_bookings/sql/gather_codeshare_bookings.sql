SELECT
		b.RecordLocator AS VY_RecordLocator ,
		SUBSTRING (fp.gds_rec_loc, 1, Len(fp.gds_rec_loc) - 2 ) AS IB_RecordLocator,
		CONVERT(varchar, b.CreatedUTC, 23) AS CreationDate,
    	pjs.DepartureDate ,
    	fp.nbr_of_pax ,
    	bp.TotalCost,
    	pjs.DepartureStation,
    	pjs.ArrivalStation,
    	dc.channel_lvl1,
		dc.channel_lvl2,
		dc.channel_lvl3,
    	pjs.TicketNumber
FROM rez.Booking b with (nolock)
INNER JOIN rez.BookingPassenger bp with (nolock) ON b.bookingid = bp.bookingid
INNER JOIN rez.PassengerJourneySegment pjs with (nolock) ON bp.passengerid = pjs.passengerid
INNER JOIN VUELING_CALCODS.dbo.factpnr fp with (nolock) ON fp.bookingId = b.BookingID
JOIN vueling_ventas.dbo.factsegment_ventaschannel fsv with (nolock) on fp.rec_loc = fsv.rec_loc
JOIN vueling_ventas.dbo.DimChannel dc with (nolock) on dc.id_channel = fsv.id_channel
WHERE
	b.OwningCarrierCode = 'VY'            --Vendidos por VY
	AND pjs.XRefCarrierCode = 'IB'        --Operados por IB
	AND PJS.BookingStatus = 'HP'          --Booking Status tipo HP
	AND b.CreatedUTC BETWEEN '{0}' AND '{1}';