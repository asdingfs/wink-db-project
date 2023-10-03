CREATE TABLE [dbo].[WINK_CUSTOMER_ACCOUNT_FILTER_LIST] (
    [id]                         INT             IDENTITY (1, 1) NOT NULL,
    [customer_id]                VARCHAR (10)    NOT NULL,
    [email]                      VARCHAR (50)    NOT NULL,
    [winks_ewallet]              DECIMAL (18, 2) DEFAULT ((0)) NULL,
    [points_ewallet]             DECIMAL (18, 2) DEFAULT ((0)) NULL,
    [last_evoucher_expired_date] DATETIME        NULL,
    [phone_no]                   VARCHAR (20)    NULL,
    [whatsapp_phone_no]          DATETIME        NULL,
    [disabled_date]              DATETIME        NOT NULL,
    [whatsapp_received_date]     DATETIME        NULL,
    [email_request]              VARCHAR (10)    DEFAULT ('0') NULL,
    [whatsapp_request]           VARCHAR (10)    DEFAULT ('0') NULL,
    [offender_status]            VARCHAR (50)    NULL,
    [locked_reason]              VARCHAR (1000)  NOT NULL,
    [remark]                     VARCHAR (1000)  NULL,
    [confiscated_status]         VARCHAR (10)    DEFAULT ('0') NULL,
    [confiscation_batch]         VARCHAR (20)    NULL,
    [status]                     VARCHAR (50)    NULL,
    [unlocked_date]              DATETIME        NULL,
    [ed_remark]                  VARCHAR (50)    NULL,
    [ed_remark_comment]          VARCHAR (1000)  NULL
);

