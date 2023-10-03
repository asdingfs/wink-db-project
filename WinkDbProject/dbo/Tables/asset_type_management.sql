CREATE TABLE [dbo].[asset_type_management] (
    [station_name]             NVARCHAR (255)  NULL,
    [asset_code]               NVARCHAR (255)  NULL,
    [asset_name]               NVARCHAR (255)  NULL,
    [asset_type_management_id] INT             IDENTITY (1, 1) NOT NULL,
    [station_id]               INT             DEFAULT ((0)) NOT NULL,
    [scan_value]               INT             DEFAULT ((0)) NOT NULL,
    [scan_interval]            DECIMAL (10, 2) DEFAULT ((24)) NULL,
    [qr_code_value]            VARCHAR (100)   DEFAULT ((50)) NOT NULL,
    [created_at]               DATETIME        NULL,
    [updated_at]               DATETIME        NULL,
    [station_group_id]         INT             DEFAULT ((0)) NOT NULL,
    [station_code]             VARCHAR (200)   NULL,
    [booked_status]            VARCHAR (100)   DEFAULT ('Avaiable') NOT NULL,
    [asset_status]             VARCHAR (10)    DEFAULT ((1)) NOT NULL,
    [special_campaign]         VARCHAR (10)    DEFAULT ('No') NOT NULL,
    [scan_start_date]          VARCHAR (50)    NULL,
    [scan_end_date]            VARCHAR (50)    NULL,
    [wink_asset_category]      VARCHAR (30)    NULL,
    PRIMARY KEY CLUSTERED ([asset_type_management_id] ASC)
);

