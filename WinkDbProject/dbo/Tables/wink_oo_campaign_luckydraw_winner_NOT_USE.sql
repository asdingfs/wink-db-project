CREATE TABLE [dbo].[wink_oo_campaign_luckydraw_winner_NOT_USE] (
    [id]                INT           IDENTITY (1, 1) NOT NULL,
    [campaign_id]       VARCHAR (100) NULL,
    [lucky_draw_id]     INT           NULL,
    [created_at]        DATETIME      NULL,
    [redemption_date]   DATETIME      NULL,
    [redemption_status] VARCHAR (10)  DEFAULT ((0)) NOT NULL,
    [updated_at]        DATETIME      NULL,
    [customer_id]       INT           NULL,
    [gps]               VARCHAR (150) NULL,
    [points]            INT           DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

