CREATE TABLE [dbo].[customer_earned_evouchers] (
    [earned_evoucher_id] INT             IDENTITY (1, 1) NOT NULL,
    [customer_id]        INT             NOT NULL,
    [redeemed_winks]     INT             NOT NULL,
    [eVoucher_code]      VARCHAR (50)    NOT NULL,
    [eVoucher_amount]    DECIMAL (10, 2) NOT NULL,
    [expired_date]       DATETIME        NULL,
    [created_at]         DATETIME        NULL,
    [used_status]        BIT             NOT NULL,
    [redeemed_date]      DATETIME        NULL,
    [updated_at]         DATETIME        NULL,
    [status]             VARCHAR (10)    DEFAULT ('enable') NOT NULL,
    PRIMARY KEY CLUSTERED ([earned_evoucher_id] ASC)
);

