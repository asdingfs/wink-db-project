CREATE TABLE [dbo].[admin_action_log] (
    [action_id]         INT           IDENTITY (1, 1) NOT NULL,
    [log_id]            INT           NOT NULL,
    [action_time]       DATETIME      NULL,
    [admin_user_name]   NVARCHAR (50) NULL,
    [action_object]     NVARCHAR (50) NULL,
    [action_type]       NVARCHAR (50) NULL,
    [action_table_name] NVARCHAR (50) NULL,
    PRIMARY KEY CLUSTERED ([action_id] ASC)
);

