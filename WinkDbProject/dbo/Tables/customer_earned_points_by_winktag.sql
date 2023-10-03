CREATE TABLE [dbo].[customer_earned_points_by_winktag] (
    [winktag_points_id]   INT           IDENTITY (1, 1) NOT NULL,
    [customer_id]         INT           NOT NULL,
    [campaign_booking_id] INT           NOT NULL,
    [points]              DECIMAL (18)  DEFAULT ((0)) NOT NULL,
    [last_scanned_time]   DATETIME      NOT NULL,
    [qr_code]             VARCHAR (200) NULL,
    [created_at]          DATETIME      NULL,
    [campaign_id]         INT           DEFAULT ((0)) NOT NULL,
    [GPS_location]        VARCHAR (200) NULL,
    [ip_address]          VARCHAR (30)  NULL,
    PRIMARY KEY CLUSTERED ([winktag_points_id] ASC)
);

