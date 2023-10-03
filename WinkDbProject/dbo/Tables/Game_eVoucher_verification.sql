CREATE TABLE [dbo].[Game_eVoucher_verification] (
    [eVoucher_verification_id] INT          IDENTITY (1, 1) NOT NULL,
    [eVoucher_code]            VARCHAR (50) NULL,
    [verification_code]        VARCHAR (50) NULL,
    [branch_id]                INT          NOT NULL,
    [created_at]               DATETIME     NOT NULL,
    [event_id]                 INT          DEFAULT ((0)) NOT NULL
);

