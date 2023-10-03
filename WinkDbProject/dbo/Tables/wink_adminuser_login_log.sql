CREATE TABLE [dbo].[wink_adminuser_login_log] (
    [id]           INT           IDENTITY (1, 1) NOT NULL,
    [admin_id]     INT           NOT NULL,
    [admin_action] VARCHAR (20)  NULL,
    [ip_address]   VARCHAR (20)  NULL,
    [created_at]   DATETIME      NULL,
    [admin_email]  VARCHAR (150) NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

