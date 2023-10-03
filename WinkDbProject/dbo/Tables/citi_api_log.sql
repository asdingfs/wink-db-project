CREATE TABLE [dbo].[citi_api_log] (
    [id]               INT            IDENTITY (1, 1) NOT NULL,
    [name]             NVARCHAR (255) NULL,
    [email]            NVARCHAR (255) NULL,
    [phone]            VARCHAR (200)  NOT NULL,
    [created_on]       DATETIME       NOT NULL,
    [application_id]   VARCHAR (200)  NULL,
    [applicationStage] VARCHAR (250)  NULL,
    [controlFlowId]    VARCHAR (500)  NULL,
    CONSTRAINT [PK_citi_api_log] PRIMARY KEY CLUSTERED ([id] ASC)
);

