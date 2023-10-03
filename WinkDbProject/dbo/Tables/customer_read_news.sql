CREATE TABLE [dbo].[customer_read_news] (
    [id]          INT      IDENTITY (1, 1) NOT NULL,
    [news_id]     INT      DEFAULT ((0)) NOT NULL,
    [customer_id] INT      DEFAULT ((0)) NOT NULL,
    [created_at]  DATETIME NULL
);

