CREATE TABLE [dbo].[merchant_partners_bak06052016] (
    [name]        VARCHAR (255) NOT NULL,
    [mas_code]    VARCHAR (255) NULL,
    [email]       VARCHAR (150) NULL,
    [created_at]  DATETIME      NULL,
    [updated_at]  DATETIME      NULL,
    [status]      VARCHAR (10)  NOT NULL,
    [logo]        VARCHAR (255) NULL,
    [industry_id] INT           NULL,
    [merchant_id] INT           IDENTITY (1, 1) NOT NULL,
    PRIMARY KEY CLUSTERED ([merchant_id] ASC)
);

