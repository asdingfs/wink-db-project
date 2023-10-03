CREATE TABLE [dbo].[webview_urls] (
    [id]         INT           IDENTITY (1, 1) NOT NULL,
    [name]       VARCHAR (200) NOT NULL,
    [url]        VARCHAR (250) NOT NULL,
    [status]     VARCHAR (10)  NOT NULL,
    [created_at] DATETIME      NOT NULL,
    CONSTRAINT [PK_webview_urls] PRIMARY KEY CLUSTERED ([id] ASC)
);

