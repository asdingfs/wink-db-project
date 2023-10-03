CREATE TABLE [dbo].[customer_action_log_d] (
    [id]              INT           IDENTITY (1, 1) NOT NULL,
    [customer_id]     INT           NULL,
    [ip_address]      VARCHAR (100) NULL,
    [customer_action] VARCHAR (20)  NULL,
    [created_at]      DATETIME      NULL,
    [token_id]        VARCHAR (100) NULL,
    [email]           VARCHAR (100) NULL,
    CONSTRAINT [PK_customer_action_log_d] PRIMARY KEY CLUSTERED ([id] ASC)
);

