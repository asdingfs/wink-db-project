CREATE TABLE [dbo].[mousetrap_action_log] (
    [action_id]     INT          IDENTITY (1, 1) NOT NULL,
    [mousetrap_id]  INT          NOT NULL,
    [ip_address]    VARCHAR (50) NOT NULL,
    [user_action]   VARCHAR (50) NOT NULL,
    [admin_email]   VARCHAR (50) NOT NULL,
    [admin_user_id] INT          NOT NULL,
    [created_at]    DATETIME     NOT NULL,
    [updated_at]    DATETIME     NOT NULL
);

