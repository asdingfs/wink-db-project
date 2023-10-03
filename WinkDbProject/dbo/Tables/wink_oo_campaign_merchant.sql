CREATE TABLE [dbo].[wink_oo_campaign_merchant] (
    [merchant_id]     INT           IDENTITY (1, 1) NOT NULL,
    [merchant_name]   VARCHAR (100) NULL,
    [branch_code]     VARCHAR (50)  NULL,
    [created_at]      DATETIME      NULL,
    [merchant_status] VARCHAR (10)  DEFAULT ((1)) NOT NULL,
    [campaign_id]     INT           DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([merchant_id] ASC)
);

