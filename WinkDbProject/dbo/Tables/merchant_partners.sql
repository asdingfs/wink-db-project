CREATE TABLE [dbo].[merchant_partners] (
    [merchant_id]            INT           IDENTITY (1, 1) NOT NULL,
    [name]                   VARCHAR (255) NOT NULL,
    [mas_code]               VARCHAR (255) NULL,
    [email]                  VARCHAR (150) NULL,
    [created_at]             DATETIME      NULL,
    [updated_at]             DATETIME      NULL,
    [status]                 VARCHAR (10)  CONSTRAINT [DF__merchant___statu__4668671F] DEFAULT ((0)) NOT NULL,
    [logo_]                  VARCHAR (255) CONSTRAINT [DF_mplogo] DEFAULT (N'winklogo1.png') NULL,
    [industry_id]            INT           CONSTRAINT [DF__merchant___indus__475C8B58] DEFAULT ((1)) NOT NULL,
    [merchant_logo_app]      VARCHAR (150) NOT NULL,
    [url]                    VARCHAR (150) NULL,
    [link_to_website_status] VARCHAR (10)  CONSTRAINT [DF__merchant___link___1B9E04AB] DEFAULT ((0)) NOT NULL,
    [logo]                   VARCHAR (150) CONSTRAINT [DF__merchant___logo2__6AE5BEB7] DEFAULT ('winklogo1.png') NOT NULL,
    [description]            VARCHAR (350) NULL,
    CONSTRAINT [PK__merchant__02BC30BA3CEC62A2] PRIMARY KEY CLUSTERED ([merchant_id] ASC)
);

