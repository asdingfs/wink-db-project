CREATE TABLE [dbo].[news_olddata_log] (
    [id]          INT            IDENTITY (1, 1) NOT NULL,
    [action_id]   INT            NOT NULL,
    [news_id]     INT            NOT NULL,
    [title]       VARCHAR (200)  NOT NULL,
    [news]        VARCHAR (5000) NOT NULL,
    [news_status] VARCHAR (10)   NOT NULL,
    [created_at]  DATETIME       NOT NULL,
    CONSTRAINT [PK_news_olddata_log] PRIMARY KEY CLUSTERED ([id] ASC)
);

