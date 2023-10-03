CREATE TABLE [dbo].[microsite_ads_tracker] (
    [id]          INT           IDENTITY (1, 1) NOT NULL,
    [source]      VARCHAR (250) NULL,
    [url]         VARCHAR (250) NULL,
    [customer_id] INT           NULL,
    [created_at]  DATETIME      NULL,
    [updated_at]  DATETIME      NULL,
    [ip_address]  VARCHAR (20)  NULL,
    CONSTRAINT [PK_microsite_app_tracker] PRIMARY KEY CLUSTERED ([id] ASC)
);

