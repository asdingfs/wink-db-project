CREATE TABLE [dbo].[app_maintenance_log] (
    [id]                 INT          IDENTITY (1, 1) NOT NULL,
    [action_id]          INT          NOT NULL,
    [app_maintenance_id] INT          NOT NULL,
    [action]             VARCHAR (50) NOT NULL,
    [created_at]         DATETIME     NOT NULL,
    CONSTRAINT [PK_app_maintenance_log] PRIMARY KEY CLUSTERED ([id] ASC)
);

