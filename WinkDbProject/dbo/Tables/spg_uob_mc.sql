CREATE TABLE [dbo].[spg_uob_mc] (
    [winner_id]    INT           IDENTITY (1, 1) NOT NULL,
    [customer_id]  INT           NOT NULL,
    [points]       DECIMAL (18)  NOT NULL,
    [qr_code]      VARCHAR (200) NOT NULL,
    [created_at]   DATETIME      NOT NULL,
    [GPS_location] VARCHAR (200) NULL,
    [ip_address]   VARCHAR (30)  NULL,
    CONSTRAINT [PK_spg_uob_mc] PRIMARY KEY CLUSTERED ([winner_id] ASC)
);

