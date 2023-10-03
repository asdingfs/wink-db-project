CREATE TABLE [dbo].[campaign_ads_banner] (
    [banner_id]    INT           IDENTITY (1, 1) NOT NULL,
    [small_banner] VARCHAR (255) NULL,
    [large_banner] VARCHAR (255) NULL,
    [large_url]    VARCHAR (255) NULL,
    [campagin_id]  INT           NULL,
    [status]       BIT           NULL,
    [created_at]   DATETIME      NULL,
    [updated_at]   DATETIME      NULL,
    [merchant_id]  INT           DEFAULT ((0)) NOT NULL,
    [small_url]    VARCHAR (255) NULL,
    PRIMARY KEY CLUSTERED ([banner_id] ASC)
);

