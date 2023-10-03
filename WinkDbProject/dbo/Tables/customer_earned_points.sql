CREATE TABLE [dbo].[customer_earned_points] (
    [earned_points_id]    INT           IDENTITY (1, 1) NOT NULL,
    [customer_id]         INT           NOT NULL,
    [campaign_booking_id] INT           NOT NULL,
    [points]              DECIMAL (18)  CONSTRAINT [DF_customer_earned_points_points] DEFAULT ((0)) NOT NULL,
    [last_scanned_time]   DATETIME      NOT NULL,
    [qr_code]             VARCHAR (200) NULL,
    [created_at]          DATETIME      NULL,
    [campaign_id]         INT           DEFAULT ((0)) NULL,
    [GPS_location]        VARCHAR (200) NULL,
    [ip_address]          VARCHAR (30)  NULL,
    CONSTRAINT [PK_customer_earned_points] PRIMARY KEY CLUSTERED ([earned_points_id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_customer_earned_points]
    ON [dbo].[customer_earned_points]([customer_id] ASC, [created_at] ASC, [campaign_id] ASC);

