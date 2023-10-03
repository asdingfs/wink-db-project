CREATE TABLE [dbo].[push_ads_tracker] (
    [id]           INT           IDENTITY (1, 1) NOT NULL,
    [type]         VARCHAR (100) NULL,
    [campaign_id]  INT           NULL,
    [customer_id]  INT           NULL,
    [device_token] VARCHAR (300) NULL,
    [created_at]   DATETIME      NULL,
    [updated_at]   DATETIME      NULL,
    [ip_address]   VARCHAR (20)  NULL,
    CONSTRAINT [PK_push_ads_tracker] PRIMARY KEY CLUSTERED ([id] ASC)
);

