CREATE TABLE [dbo].[wink_customer_login_log] (
    [id]              INT          IDENTITY (1, 1) NOT NULL,
    [customer_id]     INT          NOT NULL,
    [customer_action] VARCHAR (20) NULL,
    [ip_address]      VARCHAR (20) NULL,
    [created_at]      DATETIME     NULL,
    [login_from]      VARCHAR (50) NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

