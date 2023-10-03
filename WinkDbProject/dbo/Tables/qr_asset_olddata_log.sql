CREATE TABLE [dbo].[qr_asset_olddata_log] (
    [id]                       INT             IDENTITY (1, 1) NOT NULL,
    [action_id]                INT             NOT NULL,
    [asset_type_management_id] INT             NOT NULL,
    [old_special_campaign]     VARCHAR (10)    NOT NULL,
    [old_scan_value]           INT             NOT NULL,
    [old_interval]             DECIMAL (10, 2) NOT NULL,
    [old_scan_startdate]       DATETIME        NULL,
    [old_scan_enddate]         DATETIME        NULL,
    [old_wink_asset_category]  VARCHAR (10)    NOT NULL,
    [created_at]               DATETIME        NOT NULL,
    CONSTRAINT [PK_qr_asset_olddata_log] PRIMARY KEY CLUSTERED ([id] ASC)
);

