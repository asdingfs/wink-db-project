CREATE TABLE [dbo].[wink_products_thirdparty_evoucher] (
    [id]            INT             IDENTITY (1, 1) NOT NULL,
    [merchant_id]   INT             NULL,
    [branch_id]     INT             NULL,
    [price]         DECIMAL (10, 2) NULL,
    [eVoucher_code] VARCHAR (110)   NULL,
    [used_status]   INT             DEFAULT ((0)) NOT NULL,
    [product_id]    INT             DEFAULT ((0)) NOT NULL,
    [created_at]    DATETIME        NULL,
    [updated_at]    DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

