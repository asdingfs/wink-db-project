CREATE TABLE [dbo].[NETs_Appended_CANID_Redemption_Detail] (
    [id]              INT             IDENTITY (1, 1) NOT NULL,
    [can_id]          VARCHAR (25)    NOT NULL,
    [customer_id]     INT             NOT NULL,
    [evoucher_id]     INT             NOT NULL,
    [evoucher_amount] DECIMAL (12, 2) NOT NULL,
    [created_at]      DATETIME        NULL,
    [updated_at]      DATETIME        NULL,
    [redemption_date] DATETIME        NULL,
    [error_date]      DATETIME        NULL,
    [file_name]       VARCHAR (25)    NULL,
    [reason]          VARCHAR (50)    NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

