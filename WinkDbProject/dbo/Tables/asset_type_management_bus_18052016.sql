CREATE TABLE [dbo].[asset_type_management_bus_18052016] (
    [station_name]             NVARCHAR (255)  NULL,
    [asset_code]               NVARCHAR (255)  NULL,
    [asset_name]               NVARCHAR (255)  NULL,
    [asset_type_management_id] INT             IDENTITY (1, 1) NOT NULL,
    [station_id]               INT             NOT NULL,
    [scan_value]               INT             NOT NULL,
    [scan_interval]            DECIMAL (10, 2) NULL,
    [qr_code_value]            VARCHAR (100)   NULL,
    [created_at]               DATETIME        NULL,
    [updated_at]               DATETIME        NULL,
    [station_group_id]         INT             NOT NULL,
    [station_code]             VARCHAR (200)   NULL,
    [booked_status]            VARCHAR (100)   NOT NULL,
    PRIMARY KEY CLUSTERED ([asset_type_management_id] ASC)
);

