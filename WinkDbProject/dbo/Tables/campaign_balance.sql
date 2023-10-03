CREATE TABLE [dbo].[campaign_balance] (
    [ID]             INT      IDENTITY (1, 1) NOT NULL,
    [total_winks]    INT      DEFAULT ((0)) NULL,
    [redeemed_winks] INT      DEFAULT ((0)) NULL,
    [created_at]     DATETIME NULL,
    [updated_at]     DATETIME NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

