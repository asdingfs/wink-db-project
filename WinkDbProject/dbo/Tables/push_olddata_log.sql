CREATE TABLE [dbo].[push_olddata_log] (
    [id]                   INT            IDENTITY (1, 1) NOT NULL,
    [action_id]            INT            NOT NULL,
    [push_id]              INT            NULL,
    [notification_message] NVARCHAR (500) NULL,
    [notification_title]   NVARCHAR (250) NULL,
    [created_at]           DATETIME       NULL,
    [updated_at]           DATETIME       NULL
);

