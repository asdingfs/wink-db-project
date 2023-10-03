CREATE TABLE [dbo].[winkpoint_promotion_redemption] (
    [id]              INT             IDENTITY (1, 1) NOT NULL,
    [event_id]        INT             DEFAULT ((0)) NOT NULL,
    [customer_id]     INT             NULL,
    [redeemed_points] DECIMAL (10, 2) DEFAULT ((0)) NOT NULL,
    [redeemed_qty]    INT             DEFAULT ((0)) NOT NULL,
    [created_at]      DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

