CREATE TABLE [dbo].[wink_oo_campaign_luckydraw_detail_NOT_USE] (
    [id]              INT           IDENTITY (1, 1) NOT NULL,
    [campaign_id]     VARCHAR (100) NULL,
    [from_time]       DATETIME      NULL,
    [to_time]         DATETIME      NULL,
    [luckydraw_satus] VARCHAR (10)  NULL,
    [total_quantity]  INT           NULL,
    [answer]          VARCHAR (200) NULL,
    [merchant_code]   VARCHAR (50)  NULL,
    [prize]           VARCHAR (200) NULL,
    [prize_image]     VARCHAR (200) NULL,
    [campaign_image]  VARCHAR (100) NULL,
    [campaign_name]   VARCHAR (50)  NULL,
    [campaign_type]   VARCHAR (50)  DEFAULT ('merchant') NOT NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

