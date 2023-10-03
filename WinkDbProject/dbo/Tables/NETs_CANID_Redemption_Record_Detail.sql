CREATE TABLE [dbo].[NETs_CANID_Redemption_Record_Detail] (
    [id]                       INT             IDENTITY (1, 1) NOT NULL,
    [can_id]                   VARCHAR (25)    NOT NULL,
    [customer_id]              INT             NOT NULL,
    [evoucher_id]              INT             NOT NULL,
    [evoucher_amount]          DECIMAL (12, 2) DEFAULT ((0)) NOT NULL,
    [created_at]               DATETIME        NULL,
    [updated_at]               DATETIME        NULL,
    [redemption_date]          DATETIME        NULL,
    [redemption_status]        VARCHAR (10)    DEFAULT ('0') NOT NULL,
    [cronjob_success_date]     DATETIME        NULL,
    [cronjob_sending_date]     DATETIME        NULL,
    [cronjob_status]           VARCHAR (30)    DEFAULT ('pending') NOT NULL,
    [topup_redemption_charges] INT             DEFAULT ((0)) NOT NULL,
    [wink_charges]             INT             DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

