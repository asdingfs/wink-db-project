CREATE TABLE [dbo].[qr_asset_newdata_log] (
    [id]                       INT             IDENTITY (1, 1) NOT NULL,
    [action_id]                INT             NOT NULL,
    [asset_type_management_id] INT             NOT NULL,
    [new_special_campaign]     VARCHAR (10)    NOT NULL,
    [new_scan_value]           INT             NOT NULL,
    [new_interval]             DECIMAL (10, 2) NOT NULL,
    [new_scan_startdate]       DATETIME        NULL,
    [new_scan_enddate]         DATETIME        NULL,
    [new_wink_asset_category]  VARCHAR (10)    NOT NULL,
    [created_at]               DATETIME        NOT NULL,
    CONSTRAINT [PK_qr_asset_newdata_log] PRIMARY KEY CLUSTERED ([id] ASC)
);

