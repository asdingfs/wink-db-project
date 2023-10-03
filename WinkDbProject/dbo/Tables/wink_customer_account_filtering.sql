CREATE TABLE [dbo].[wink_customer_account_filtering] (
    [id]                      INT             IDENTITY (1, 1) NOT NULL,
    [customer_id]             INT             NULL,
    [registered_email]        VARCHAR (100)   NULL,
    [WINKs_in_eWallet]        DECIMAL (10, 2) NULL,
    [points_in_eWallet]       DECIMAL (10, 2) NULL,
    [last_expired_evoucher]   VARCHAR (10)    NULL,
    [registered_phone_no]     VARCHAR (10)    NULL,
    [whatsapp_phone_no]       VARCHAR (10)    NULL,
    [diasbled_date]           DATETIME        NULL,
    [whatsapp_received_date]  DATETIME        NULL,
    [email_request_status]    VARCHAR (10)    NULL,
    [whatsapp_request_status] VARCHAR (10)    NULL,
    [offender_status]         VARCHAR (50)    NULL,
    [reason]                  VARCHAR (250)   NULL,
    [confiscated_status]      VARCHAR (10)    NULL,
    [confiscation_batch]      VARCHAR (50)    NULL,
    [filtering_status]        VARCHAR (50)    NULL,
    [unlocked_date]           DATETIME        NULL,
    [remark]                  VARCHAR (250)   NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

