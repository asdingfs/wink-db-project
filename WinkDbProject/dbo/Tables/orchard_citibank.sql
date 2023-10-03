CREATE TABLE [dbo].[orchard_citibank] (
    [id]                                INT           IDENTITY (1, 1) NOT NULL,
    [customer_id]                       INT           NOT NULL,
    [campaign_booking_id]               INT           NOT NULL,
    [points]                            DECIMAL (18)  NOT NULL,
    [last_scanned_time]                 DATETIME      NOT NULL,
    [qr_code]                           VARCHAR (200) NULL,
    [created_at]                        DATETIME      NULL,
    [campaign_id]                       INT           NULL,
    [GPS_location]                      VARCHAR (200) NULL,
    [ip_address]                        VARCHAR (30)  NULL,
    [corbrand_card]                     VARCHAR (50)  NULL,
    [registered_date_for_corbrand_card] DATETIME      NULL,
    CONSTRAINT [PK_orchard_citibank] PRIMARY KEY CLUSTERED ([id] ASC)
);

