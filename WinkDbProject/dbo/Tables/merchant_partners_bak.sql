CREATE TABLE [dbo].[merchant_partners_bak] (
    [merchant_id] INT           NOT NULL,
    [name]        VARCHAR (255) NOT NULL,
    [mas_code]    VARCHAR (255) NULL,
    [email]       VARCHAR (150) NULL,
    [created_at]  DATETIME      NULL,
    [updated_at]  DATETIME      NULL,
    [status]      VARCHAR (10)  DEFAULT ((0)) NOT NULL,
    [logo]        VARCHAR (255) NULL,
    [industry_id] INT           NULL
);

