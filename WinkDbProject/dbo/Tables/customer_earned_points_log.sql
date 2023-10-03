CREATE TABLE [dbo].[customer_earned_points_log] (
    [earned_points_id]    INT           IDENTITY (1, 1) NOT NULL,
    [customer_id]         INT           NOT NULL,
    [campaign_booking_id] INT           NOT NULL,
    [points]              DECIMAL (18)  NOT NULL,
    [last_scanned_time]   DATETIME      NOT NULL,
    [qr_code]             VARCHAR (200) NULL,
    [created_at]          DATETIME      NULL,
    [campaign_id]         INT           NULL,
    PRIMARY KEY CLUSTERED ([earned_points_id] ASC)
);

