CREATE TABLE [dbo].[wink_oo_campaign] (
    [campaign_id]         INT           IDENTITY (1, 1) NOT NULL,
    [campaign_status]     VARCHAR (10)  NULL,
    [campaign_image]      VARCHAR (100) NULL,
    [campaign_name]       VARCHAR (50)  NULL,
    [created_at]          DATETIME      NULL,
    [updated_date]        DATETIME      NULL,
    [merchant_id]         INT           NULL,
    [winktag_campaign_id] INT           DEFAULT ((0)) NOT NULL,
    [prize]               VARCHAR (100) NULL,
    [prize_image]         VARCHAR (100) NULL,
    PRIMARY KEY CLUSTERED ([campaign_id] ASC)
);

