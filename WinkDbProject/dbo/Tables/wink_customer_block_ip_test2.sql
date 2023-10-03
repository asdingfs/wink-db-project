CREATE TABLE [dbo].[wink_customer_block_ip_test2] (
    [id]         INT           IDENTITY (1, 1) NOT NULL,
    [ip_address] VARCHAR (100) NULL,
    [created_at] DATETIME      NULL,
    [updated_at] DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

