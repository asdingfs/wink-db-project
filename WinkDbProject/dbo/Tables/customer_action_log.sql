CREATE TABLE [dbo].[customer_action_log] (
    [id]              INT           IDENTITY (1, 1) NOT NULL,
    [customer_id]     INT           NULL,
    [ip_address]      VARCHAR (100) NULL,
    [customer_action] VARCHAR (20)  NULL,
    [created_at]      DATETIME      NULL,
    [token_id]        VARCHAR (100) NULL,
    [email]           VARCHAR (100) NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_customer_action_log]
    ON [dbo].[customer_action_log]([customer_id] ASC, [created_at] ASC);

