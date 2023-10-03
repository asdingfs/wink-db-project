CREATE TABLE [dbo].[customer_login_action_log] (
    [id]          INT           IDENTITY (1, 1) NOT NULL,
    [auth_token]  VARCHAR (255) NOT NULL,
    [customer_id] INT           NOT NULL,
    [created_at]  DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([id] ASC),
    UNIQUE NONCLUSTERED ([auth_token] ASC)
);

