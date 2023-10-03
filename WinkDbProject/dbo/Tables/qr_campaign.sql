CREATE TABLE [dbo].[qr_campaign] (
    [id]                  INT           IDENTITY (1, 1) NOT NULL,
    [customer_id]         INT           NOT NULL,
    [campaign_id]         INT           NOT NULL,
    [qr_code]             VARCHAR (200) NULL,
    [points]              DECIMAL (18)  NULL,
    [winning_status]      VARCHAR (5)   NULL,
    [GPS_location]        VARCHAR (200) NULL,
    [ip_address]          VARCHAR (30)  NULL,
    [created_at]          DATETIME      NULL,
    [redemption_code]     VARCHAR (30)  NULL,
    [redemption_status]   VARCHAR (5)   NULL,
    [redeemed_on]         DATETIME      NULL,
    [redemption_location] VARCHAR (200) NULL,
    CONSTRAINT [PK_qr_campaign] PRIMARY KEY CLUSTERED ([id] ASC)
);

