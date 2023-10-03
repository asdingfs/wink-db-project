CREATE TABLE [dbo].[customer_action_log_b] (
    [id]              INT           IDENTITY (1, 1) NOT NULL,
    [customer_id]     INT           NULL,
    [ip_address]      VARCHAR (100) NULL,
    [customer_action] VARCHAR (20)  NULL,
    [created_at]      DATETIME      NULL,
    [token_id]        VARCHAR (100) NULL,
    [email]           VARCHAR (100) NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

