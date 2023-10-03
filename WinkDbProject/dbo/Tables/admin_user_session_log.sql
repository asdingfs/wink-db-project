CREATE TABLE [dbo].[admin_user_session_log] (
    [id]           INT           IDENTITY (1, 1) NOT NULL,
    [session_id]   INT           NULL,
    [admin_email]  VARCHAR (150) NULL,
    [admin_id]     INT           NULL,
    [admin_action] VARCHAR (20)  NULL,
    [ip_address]   VARCHAR (20)  NULL,
    [created_at]   DATETIME      NULL,
    CONSTRAINT [PK_admin_user_session_log] PRIMARY KEY CLUSTERED ([id] ASC)
);

