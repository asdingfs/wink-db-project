CREATE TABLE [dbo].[avatar] (
    [id]          INT           IDENTITY (1, 1) NOT NULL,
    [avatarimage] VARCHAR (255) NOT NULL,
    [status]      VARCHAR (10)  DEFAULT ((1)) NOT NULL,
    [created_at]  DATETIME      NULL,
    [updated_at]  DATETIME      NULL,
    [avatar_name] VARCHAR (150) NULL,
    [orderlist]   INT           NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

