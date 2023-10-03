CREATE TABLE [dbo].[merchant_partners_address_bak11052016] (
    [address_id]     INT           NOT NULL,
    [merchant_id]    INT           NOT NULL,
    [outlet_address] VARCHAR (255) NULL,
    [postal_code]    VARCHAR (10)  NULL,
    [city]           VARCHAR (10)  NULL,
    [country]        VARCHAR (10)  NULL,
    [phone]          VARCHAR (10)  NULL,
    [outlet_email]   VARCHAR (15)  NULL,
    [outlet_no]      INT           NULL,
    [outlet_name]    VARCHAR (150) NULL,
    [created_at]     DATETIME      NULL,
    [updated_at]     DATETIME      NULL,
    [status]         VARCHAR (10)  NOT NULL,
    [logo]           VARCHAR (255) NULL
);

