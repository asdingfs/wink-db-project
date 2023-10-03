CREATE TABLE [dbo].[customer_earned_winks] (
    [earned_winks_id] INT      IDENTITY (1, 1) NOT NULL,
    [customer_id]     INT      DEFAULT ((0)) NOT NULL,
    [merchant_id]     INT      DEFAULT ((0)) NOT NULL,
    [total_winks]     INT      DEFAULT ((0)) NOT NULL,
    [redeemed_points] INT      DEFAULT ((0)) NOT NULL,
    [created_at]      DATETIME NULL,
    [updated_at]      DATETIME NULL,
    [campaign_id]     INT      DEFAULT ((0)) NOT NULL
);

