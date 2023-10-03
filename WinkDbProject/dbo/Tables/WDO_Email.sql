CREATE TABLE [dbo].[WDO_Email] (
    [id]          INT            IDENTITY (1, 1) NOT NULL,
    [campaign_id] INT            NULL,
    [subject]     VARCHAR (200)  NULL,
    [greeting]    VARCHAR (100)  NULL,
    [first_part]  VARCHAR (250)  NULL,
    [main_body]   VARCHAR (2000) NULL,
    [validity]    VARCHAR (10)   NULL,
    [created_at]  DATETIME       NULL,
    CONSTRAINT [PK_WTO_Email] PRIMARY KEY CLUSTERED ([id] ASC)
);

