CREATE TABLE [dbo].[bus_import] (
    [station_name]     NVARCHAR (255) NULL,
    [asset_code]       NVARCHAR (255) NULL,
    [asset_name]       NVARCHAR (255) NULL,
    [station_id]       FLOAT (53)     NULL,
    [scan_value]       FLOAT (53)     NULL,
    [scan_interval]    FLOAT (53)     NULL,
    [qr_code_value]    NVARCHAR (255) NULL,
    [created_at]       DATETIME       NULL,
    [updated_at]       DATETIME       NULL,
    [station_group_id] FLOAT (53)     NULL,
    [station_code]     NVARCHAR (255) NULL,
    [booked_status]    NVARCHAR (255) NULL
);

