CREATE TABLE [dbo].[redeemed_merchant_list] (
    [merchant_id]      INT           NULL,
    [merchant_name]    VARCHAR (200) NULL,
    [merchant_address] VARCHAR (250) NULL,
    [mas_code]         VARCHAR (50)  NULL,
    [logo_name]        VARCHAR (100) NULL,
    [id]               INT           IDENTITY (1, 1) NOT NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

