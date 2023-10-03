CREATE TABLE [dbo].[wink_news] (
    [id]          INT            IDENTITY (1, 1) NOT NULL,
    [news_status] VARCHAR (10)   DEFAULT ('0') NOT NULL,
    [created_at]  DATETIME       NULL,
    [updated_at]  DATETIME       NULL,
    [title]       VARCHAR (200)  NULL,
    [news]        VARCHAR (5000) NOT NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

