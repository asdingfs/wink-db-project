CREATE TABLE [dbo].[wink_oo_campaign_winner_log] (
    [id]                 INT           IDENTITY (1, 1) NOT NULL,
    [campaign_id]        VARCHAR (100) NULL,
    [created_at]         DATETIME      NULL,
    [redemption_date]    DATETIME      NULL,
    [redemption_status]  VARCHAR (10)  DEFAULT ((0)) NOT NULL,
    [updated_at]         DATETIME      NULL,
    [customer_id]        INT           NULL,
    [gps]                VARCHAR (150) NULL,
    [points]             INT           DEFAULT ((0)) NOT NULL,
    [answer]             VARCHAR (50)  NULL,
    [campaign_timing_id] INT           NULL,
    [branch_code]        VARCHAR (10)  NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

