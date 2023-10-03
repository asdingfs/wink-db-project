CREATE TABLE [dbo].[customer_delete_news] (
    [id]          INT      IDENTITY (1, 1) NOT NULL,
    [news_id]     INT      NULL,
    [customer_id] INT      NULL,
    [created_at]  DATETIME NULL,
    [updated_at]  DATETIME NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

