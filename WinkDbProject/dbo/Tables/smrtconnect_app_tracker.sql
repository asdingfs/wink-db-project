CREATE TABLE [dbo].[smrtconnect_app_tracker] (
    [id]         INT           IDENTITY (1, 1) NOT NULL,
    [url]        VARCHAR (250) NULL,
    [created_at] DATETIME      NULL,
    [updated_at] DATETIME      NULL,
    [ip_address] VARCHAR (20)  NULL,
    [os]         VARCHAR (100) NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

