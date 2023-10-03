CREATE TABLE [dbo].[asset_type_management_old] (
    [asset_type_management_id]   INT             IDENTITY (1, 1) NOT NULL,
    [station_id]                 INT             NOT NULL,
    [asset_type_id]              INT             NOT NULL,
    [scan_value]                 INT             NOT NULL,
    [scan_interval]              DECIMAL (10, 2) NULL,
    [qr_code_value]              VARCHAR (100)   NOT NULL,
    [created_at]                 DATETIME        NULL,
    [updated_at]                 DATETIME        NULL,
    [station_group_id]           INT             CONSTRAINT [DF_asset_type_management_asset_type_group_id] DEFAULT ((0)) NOT NULL,
    [asset_type_name]            VARCHAR (255)   NULL,
    [asset_type_code]            VARCHAR (200)   NULL,
    [asset_type_management_name] VARCHAR (255)   NULL,
    [station_code]               VARCHAR (200)   NULL,
    PRIMARY KEY CLUSTERED ([asset_type_management_id] ASC)
);

