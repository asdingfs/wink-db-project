CREATE TABLE [dbo].[merchant_partners_old] (
    [merchant_id] INT           IDENTITY (1, 1) NOT NULL,
    [name]        VARCHAR (255) NOT NULL,
    [mas_code]    VARCHAR (255) NULL,
    [email]       VARCHAR (150) NULL,
    [created_at]  DATETIME      NULL,
    [updated_at]  DATETIME      NULL,
    [status]      VARCHAR (10)  DEFAULT ((0)) NOT NULL,
    [logo]        VARCHAR (255) NULL,
    PRIMARY KEY CLUSTERED ([merchant_id] ASC)
);

