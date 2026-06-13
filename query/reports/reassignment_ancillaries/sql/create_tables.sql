CREATE TABLE IF NOT EXISTS dbo.stg_sales_report_reassignment_ancillaries_allotments
(
    ClassOfService varchar(8)
);


CREATE TABLE IF NOT EXISTS dbo.stg_sales_report_reassignment_ancillaries_add_fees
(
    RecordLocator  char(6),
    BookingID      bigint,
    LastName       nvarchar(32),
    CreatedBooking datetime,
    ClassOfService varchar(8),
    PassengerID    bigint,
    SegmentID      bigint,
    SSRCode        varchar(4),
    CreatedFee     datetime,
    ModifiedUTC    datetime,
    Status         varchar(3) not null,
    Deleted      datetime
);

CREATE TABLE IF NOT EXISTS dbo.stg_sales_report_reassignment_ancillaries_cancel_fees
(
    RecordLocator  char(6),
    BookingID      bigint,
    LastName       nvarchar(32),
    CreatedBooking datetime,
    ClassOfService varchar(8),
    PassengerID    bigint,
    SegmentID      bigint,
    SSRCode        varchar(4),
    CreateFee      datetime,
    ModifiedUTC    datetime,
    Status         varchar(7) not null,
    Deleted      datetime
);


CREATE TABLE IF NOT EXISTS  dbo.stg_sales_report_reassignment_ancillaries_result
(
    RecordLocator    char(6),
    BookingID        bigint,
    LastName         nvarchar(32),
    CreatedBooking   datetime,
    ClassOfService   varchar(8),
    passengerid      bigint,
    FlightNumber     char(4),
    DepartureDate    date,
    CarrierCode      varchar(3),
    DepartureStation char(3),
    ArrivalStation   char(3),
    ssrcode          varchar(4),
    createfee        datetime,
    ModifiedUTC      datetime,
    Status           varchar(7) not null,
    Deleted       datetime
);
