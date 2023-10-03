CREATE TABLE [dbo].[customer_authentication_token] (
    [id]          INT           IDENTITY (1, 1) NOT NULL,
    [auth_token]  VARCHAR (255) NOT NULL,
    [customer_id] INT           NOT NULL,
    PRIMARY KEY CLUSTERED ([id] ASC),
    UNIQUE NONCLUSTERED ([auth_token] ASC),
    UNIQUE NONCLUSTERED ([customer_id] ASC)
);

