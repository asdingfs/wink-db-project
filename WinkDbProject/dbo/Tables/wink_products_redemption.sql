CREATE TABLE [dbo].[wink_products_redemption] (
    [id]                     INT           IDENTITY (1, 1) NOT NULL,
    [customer_id]            INT           NULL,
    [eVoucher_id]            INT           NULL,
    [product_id]             VARCHAR (100) NULL,
    [created_at]             DATETIME      NULL,
    [updated_at]             DATETIME      NULL,
    [branch_id]              INT           CONSTRAINT [DF__wink_prod__branc__0B679CE2] DEFAULT ((0)) NOT NULL,
    [thirdparty_eVoucher_id] INT           CONSTRAINT [DF__wink_prod__third__37461F20] DEFAULT ((0)) NULL,
    CONSTRAINT [PK__wink_pro__3213E83F48420859] PRIMARY KEY CLUSTERED ([id] ASC)
);

