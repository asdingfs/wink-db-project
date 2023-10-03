CREATE TABLE [dbo].[promo_banner_ads_tracker] (
    [id]          INT           IDENTITY (1, 1) NOT NULL,
    [url_id]      INT           NULL,
    [url]         VARCHAR (250) NULL,
    [customer_id] INT           NULL,
    [created_at]  DATETIME      NULL,
    [updated_at]  DATETIME      NULL,
    [ip_address]  VARCHAR (20)  NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

