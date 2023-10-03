CREATE TABLE [dbo].[wink_app_action] (
    [id]            INT           IDENTITY (1, 1) NOT NULL,
    [action_name]   VARCHAR (150) NULL,
    [action_status] INT           DEFAULT ((1)) NULL,
    [created_at]    DATETIME      NULL,
    [name]          VARCHAR (50)  NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

