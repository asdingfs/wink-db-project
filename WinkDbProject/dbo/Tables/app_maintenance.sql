CREATE TABLE [dbo].[app_maintenance] (
    [id]         INT          IDENTITY (1, 1) NOT NULL,
    [action]     VARCHAR (50) NOT NULL,
    [created_at] DATETIME     NOT NULL,
    CONSTRAINT [PK_app_maintenance] PRIMARY KEY CLUSTERED ([id] ASC)
);

