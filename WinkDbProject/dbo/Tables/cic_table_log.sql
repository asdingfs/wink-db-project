CREATE TABLE [dbo].[cic_table_log] (
    [id]               INT             IDENTITY (1, 1) NOT NULL,
    [customer_id]      INT             NULL,
    [can_id]           VARCHAR (25)    NULL,
    [nric]             VARCHAR (50)    NULL,
    [dob]              VARCHAR (20)    NULL,
    [amount]           DECIMAL (10, 2) NULL,
    [total_points]     DECIMAL (10, 2) NULL,
    [transaction_fees] DECIMAL (10, 2) NULL,
    [reason]           VARCHAR (250)   NULL,
    [created_at]       DATETIME        NULL,
    [import_file_id]   INT             DEFAULT ((0)) NOT NULL,
    [cic_file_name]    VARCHAR (150)   NULL,
    [action_type]      VARCHAR (50)    NULL,
    [action_user_id]   INT             NULL,
    [action_email]     VARCHAR (50)    NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

