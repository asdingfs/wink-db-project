CREATE TABLE [dbo].[NETs_CANID_Redemption_Record_SendingLog] (
    [id]                   INT             IDENTITY (1, 1) NOT NULL,
    [can_id]               VARCHAR (25)    NOT NULL,
    [customer_id]          INT             NOT NULL,
    [evoucher_id]          INT             NOT NULL,
    [evoucher_amount]      DECIMAL (12, 2) NOT NULL,
    [created_at]           DATETIME        NULL,
    [updated_at]           DATETIME        NULL,
    [redemption_date]      DATETIME        NULL,
    [cronjob_success_date] DATETIME        NULL,
    [cronjob_sending_date] DATETIME        NULL,
    [cronjob_status]       VARCHAR (30)    NOT NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

