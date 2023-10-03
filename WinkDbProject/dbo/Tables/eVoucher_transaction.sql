CREATE TABLE [dbo].[eVoucher_transaction] (
    [ID]                INT             IDENTITY (1, 1) NOT NULL,
    [transaction_id]    INT             DEFAULT ((1000000000)) NOT NULL,
    [merchant_id]       INT             DEFAULT ((0)) NOT NULL,
    [branch_code]       INT             DEFAULT ((0)) NOT NULL,
    [eVoucher_id]       INT             DEFAULT ((0)) NOT NULL,
    [eVoucher_amount]   DECIMAL (10, 2) DEFAULT ((0)) NOT NULL,
    [customer_id]       INT             DEFAULT ((0)) NOT NULL,
    [created_at]        DATETIME        NULL,
    [updated_at]        DATETIME        NULL,
    [customer_name]     VARCHAR (255)   NULL,
    [customer_email]    VARCHAR (255)   NULL,
    [verification_id]   VARCHAR (255)   NULL,
    [verification_code] VARCHAR (255)   NULL,
    [transation_status] VARCHAR (20)    CONSTRAINT [DF__eVoucher___trans__4707859D] DEFAULT ('success') NOT NULL,
    [order_no]          VARCHAR (20)    NULL,
    PRIMARY KEY CLUSTERED ([ID] ASC)
);

