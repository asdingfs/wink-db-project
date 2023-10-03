CREATE TABLE [dbo].[wink_products] (
    [id]              INT             IDENTITY (1, 1) NOT NULL,
    [product_name]    VARCHAR (50)    NULL,
    [sku]             VARCHAR (50)    NULL,
    [merchant_id]     INT             NULL,
    [branch_id]       INT             NULL,
    [created_at]      DATETIME        NULL,
    [qty]             INT             DEFAULT ((0)) NOT NULL,
    [price]           DECIMAL (10, 2) DEFAULT ((0)) NOT NULL,
    [redeemed_qty]    INT             DEFAULT ((0)) NOT NULL,
    [success_message] VARCHAR (200)   NULL,
    [product_status]  INT             DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

