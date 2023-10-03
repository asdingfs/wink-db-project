CREATE TABLE [dbo].[news_newdata_log] (
    [id]              INT            IDENTITY (1, 1) NOT NULL,
    [action_id]       INT            NOT NULL,
    [new_news_id]     INT            NOT NULL,
    [new_title]       VARCHAR (200)  NOT NULL,
    [new_news]        VARCHAR (5000) NOT NULL,
    [new_news_status] VARCHAR (10)   NOT NULL,
    [created_at]      DATETIME       NOT NULL,
    CONSTRAINT [PK_news_newdata_log] PRIMARY KEY CLUSTERED ([id] ASC)
);

