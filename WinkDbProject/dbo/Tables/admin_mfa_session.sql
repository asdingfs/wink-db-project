CREATE TABLE [dbo].[admin_mfa_session] (
    [id]           INT           IDENTITY (1, 1) NOT NULL,
    [admin_log_id] INT           NULL,
    [admin_id]     INT           NOT NULL,
    [admin_email]  VARCHAR (100) NOT NULL,
    [session_code] INT           NOT NULL,
    [created_at]   DATETIME      NOT NULL,
    [expired_at]   DATETIME      NOT NULL,
    [status]       INT           NOT NULL,
    CONSTRAINT [PK_admin_mfa_session] PRIMARY KEY CLUSTERED ([id] ASC)
);

