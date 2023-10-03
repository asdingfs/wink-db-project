CREATE TABLE [dbo].[wink_gate_points_earned] (
    [id]           INT           IDENTITY (1, 1) NOT NULL,
    [customer_id]  INT           NOT NULL,
    [points]       INT           NOT NULL,
    [assetId]      INT           NOT NULL,
    [bookingId]    INT           NULL,
    [ip_address]   VARCHAR (30)  NULL,
    [GPS_location] VARCHAR (200) NULL,
    [created_at]   DATETIME      NOT NULL,
    [expired_at]   DATETIME      NULL,
    [redeemed_at]  DATETIME      NULL,
    CONSTRAINT [CompKey_Hits] PRIMARY KEY CLUSTERED ([customer_id] ASC, [created_at] ASC, [assetId] ASC)
);

