CREATE TABLE [dbo].[asset_management_booking] (
    [booking_id]               INT           IDENTITY (1, 1) NOT NULL,
    [campaign_id]              INT           NOT NULL,
    [asset_type_management_id] INT           DEFAULT ((0)) NOT NULL,
    [scan_value]               INT           NOT NULL,
    [scan_interval]            FLOAT (53)    NOT NULL,
    [start_date]               DATETIME      NOT NULL,
    [end_date]                 DATETIME      NOT NULL,
    [created_at]               DATETIME      NULL,
    [updated_at]               DATETIME      NULL,
    [merchant_id]              INT           NULL,
    [station_id]               INT           NULL,
    [station_code]             VARCHAR (150) NULL,
    [asset_type_name]          VARCHAR (100) NULL,
    [asset_type_code]          VARCHAR (100) NULL,
    [qr_code_value]            VARCHAR (200) NULL,
    [station_group_id]         INT           NULL,
    [booked_status]            VARCHAR (50)  CONSTRAINT [booked_status] DEFAULT (N'TRUE') NULL,
    [event_status]             VARCHAR (10)  DEFAULT ((0)) NOT NULL,
    [image_name]               VARCHAR (250) NULL,
    [image_url]                VARCHAR (250) NULL,
    [image_id]                 INT           DEFAULT ((0)) NOT NULL,
    [winktag_id]               INT           DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([booking_id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_asset_management_booking]
    ON [dbo].[asset_management_booking]([qr_code_value] ASC, [start_date] ASC, [end_date] ASC);

