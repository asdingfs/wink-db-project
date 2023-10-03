﻿CREATE TABLE [dbo].[asset_management_booking_v2] (
    [booking_id]               INT           IDENTITY (1, 1) NOT NULL,
    [campaign_id]              INT           NOT NULL,
    [asset_type_management_id] INT           NOT NULL,
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
    [booked_status]            VARCHAR (50)  NULL,
    PRIMARY KEY CLUSTERED ([booking_id] ASC)
);

