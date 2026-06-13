select distinct
    B.RecordLocator as PNR,
    PFC.CreatedUTC as creation_bundle_date,
    count(1) as num_bundle,
    PFC.ChargeDetail as bundle_type,
    sum(PFC.chargeamount) as bundle_revenue,
    case
       when B.ChannelType in (4, 5) then 'mobile' -- ('API', 'DigitalAPI')
        when B.ChannelType in (2, 6) then 'desktop' -- ('Web', 'DigitalWeb')
    end as [platform],
    PFC.ChargeCode as Feecode,
    case when B.BookingUTC < B.ModifiedUTC then 'Manage my booking' else 'Booking Flow' end as flown
from ODS_DATABASE.REZ.PassengerFeeCharge PFC
    inner join ODS_DATABASE.rez.BookingPassenger BP on PFC.PassengerID = BP.PassengerID
    inner join ODS_DATABASE.rez.Booking B on B.BookingID = BP.BookingID
where
    PFC.CreatedUTC between DATEADD(hour, -2,  GETDATE()) and DATEADD(hour, 2, GETDATE())
    and PFC.ChargeCode in ('VCB1', 'VCB2', 'VCB3')
    and PFC.ChargeDetail in ('Fly bundle', 'Fly Grande')
group by B.RecordLocator,
    PFC.CreatedUTC,
    PFC.ChargeDetail,
    case
       when B.ChannelType in (4, 5) then 'mobile'
        when B.ChannelType in (2, 6) then 'desktop'
    end,
    PFC.ChargeCode,
    case when BookingUTC < B.ModifiedUTC then 'Manage my booking' else 'Booking Flow' end;