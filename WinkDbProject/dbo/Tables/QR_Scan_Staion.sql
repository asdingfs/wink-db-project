CREATE TABLE [dbo].[QR_Scan_Staion] (
    [id]            INT             IDENTITY (1, 1) NOT NULL,
    [station_code]  VARCHAR (255)   NOT NULL,
    [station_name]  VARCHAR (255)   NOT NULL,
    [time_interval] DECIMAL (10, 2) DEFAULT ((0)) NULL,
    [created_at]    DATETIME        NULL,
    [updated_at]    DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

