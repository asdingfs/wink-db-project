CREATE TABLE [dbo].[WiFi_Tracker] (
    [id]          INT           IDENTITY (1, 1) NOT NULL,
    [ap_id]       VARCHAR (100) NOT NULL,
    [mac_address] VARCHAR (150) NOT NULL,
    [created_at]  DATETIME      NOT NULL,
    [device_type] VARCHAR (150) NULL,
    [timestamp]   DATETIME      NOT NULL,
    CONSTRAINT [PK_WiFi_Tracker] PRIMARY KEY CLUSTERED ([id] ASC)
);

