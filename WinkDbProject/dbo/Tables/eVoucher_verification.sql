CREATE TABLE [dbo].[eVoucher_verification] (
    [eVoucher_verification_id] INT          IDENTITY (1, 1) NOT NULL,
    [eVoucher_code]            VARCHAR (50) NOT NULL,
    [verification_code]        VARCHAR (50) NOT NULL,
    [customer_id]              INT          NOT NULL,
    [branch_id]                INT          NOT NULL,
    [created_at]               DATETIME     NOT NULL,
    [valid_till]               DATETIME     NOT NULL,
    [eVoucher_id]              INT          DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([eVoucher_verification_id] ASC)
);

