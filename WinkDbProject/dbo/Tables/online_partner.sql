CREATE TABLE [dbo].[online_partner] (
    [id]             INT           IDENTITY (1, 1) NOT NULL,
    [partner_name]   VARCHAR (200) NULL,
    [logo]           VARCHAR (200) NULL,
    [url]            VARCHAR (250) NULL,
    [partner_status] VARCHAR (10)  NULL,
    [created_at]     DATETIME      NULL,
    [updated_at]     DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

