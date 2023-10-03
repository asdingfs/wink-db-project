CREATE TABLE [dbo].[push_notification] (
    [id]                   INT             IDENTITY (1, 1) NOT NULL,
    [notification_message] NVARCHAR (1000) NULL,
    [created_on]           DATETIME        NULL,
    [notification_title]   NVARCHAR (250)  NULL,
    [type]                 VARCHAR (255)   NULL,
    [img_url]              VARCHAR (1000)  NULL,
    [goToPage]             VARCHAR (255)   NULL,
    CONSTRAINT [PK__push_not__3213E83FECEFA76D] PRIMARY KEY CLUSTERED ([id] ASC)
);

