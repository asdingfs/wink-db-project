CREATE TABLE [dbo].[WINK_eVoucherConversion_Partner] (
    [id]                      INT           IDENTITY (1, 1) NOT NULL,
    [image_name]              VARCHAR (50)  NULL,
    [redemption_partner_name] VARCHAR (100) NULL,
    [partner_status]          INT           NULL,
    [created_at]              DATETIME      NULL,
    [title]                   VARCHAR (100) NULL,
    [android_image_name]      VARCHAR (100) NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

