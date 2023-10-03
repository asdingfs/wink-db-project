CREATE TABLE [dbo].[WINK_Redemption_Detail_With_WINK_Fees] (
    [id]                      INT             IDENTITY (1, 1) NOT NULL,
    [merchant_id]             INT             NULL,
    [total_redeemed_winks]    DECIMAL (10, 2) NULL,
    [total_redeemed_amount]   DECIMAL (10, 2) DEFAULT ((0)) NOT NULL,
    [wink_fee]                DECIMAL (10, 2) DEFAULT ((0)) NOT NULL,
    [balance_redeemed_winks]  DECIMAL (10, 2) DEFAULT ((0)) NOT NULL,
    [balance_redeemed_amount] DECIMAL (10, 2) DEFAULT ((0)) NOT NULL,
    [created_at]              DATETIME        NULL,
    [updated_at]              DATETIME        NULL,
    [evoucher_id]             INT             DEFAULT ((0)) NOT NULL,
    [customer_id]             INT             NULL,
    [wink_fee_amount]         DECIMAL (10, 2) DEFAULT ((0)) NOT NULL,
    [wink_fees_id]            INT             NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

