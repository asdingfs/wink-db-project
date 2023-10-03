CREATE TABLE [dbo].[asset_type_management_train_new_1] (
    [station_name]             NVARCHAR (255)  NULL,
    [asset_code]               NVARCHAR (255)  NULL,
    [asset_name]               NVARCHAR (255)  NULL,
    [asset_type_management_id] INT             IDENTITY (1, 1) NOT NULL,
    [station_id]               INT             NOT NULL,
    [scan_value]               INT             DEFAULT ((1)) NOT NULL,
    [scan_interval]            DECIMAL (10, 2) DEFAULT ((24)) NOT NULL,
    [qr_code_value]            VARCHAR (100)   NULL,
    [created_at]               DATETIME        NULL,
    [updated_at]               DATETIME        NULL,
    [station_group_id]         INT             DEFAULT ((0)) NOT NULL,
    [station_code]             VARCHAR (200)   NULL,
    [booked_status]            VARCHAR (100)   DEFAULT ('Avaiable') NOT NULL
);

