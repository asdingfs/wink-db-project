CREATE TABLE [dbo].[create_citi_api_report] (
    [id]               INT            IDENTITY (1, 1) NOT NULL,
    [name]             NVARCHAR (255) NULL,
    [email]            NVARCHAR (255) NULL,
    [phone]            VARCHAR (200)  NOT NULL,
    [created_on]       DATETIME       NOT NULL,
    [application_id]   VARCHAR (200)  NULL,
    [controlFlowId]    VARCHAR (500)  NULL,
    [applicationStage] VARCHAR (250)  NULL,
    CONSTRAINT [PK_create_citi_api_report] PRIMARY KEY CLUSTERED ([id] ASC)
);

