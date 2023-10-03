CREATE TABLE [dbo].[merchant_redemption_outlets] (
    [outlet_id]      INT           IDENTITY (1, 1) NOT NULL,
    [outlet_address] VARCHAR (255) NULL,
    [postal_code]    VARCHAR (10)  NULL,
    [city]           VARCHAR (10)  DEFAULT ('Singapore') NOT NULL,
    [country]        VARCHAR (10)  DEFAULT ('Singapore') NOT NULL,
    [phone]          VARCHAR (10)  NULL,
    [outlet_email]   VARCHAR (15)  NULL,
    [outlet_code]    INT           NULL,
    [outlet_name]    VARCHAR (150) NULL,
    [created_at]     DATETIME      NULL,
    [updated_at]     DATETIME      NULL,
    [status]         VARCHAR (5)   DEFAULT ((1)) NOT NULL,
    PRIMARY KEY CLUSTERED ([outlet_id] ASC)
);

