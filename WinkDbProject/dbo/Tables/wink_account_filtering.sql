﻿CREATE TABLE [dbo].[wink_account_filtering] (
    [id]                         INT             IDENTITY (1, 1) NOT NULL,
    [customer_id]                INT             NULL,
    [registered_email]           VARCHAR (100)   NULL,
    [WINKs_in_eWallet]           DECIMAL (10, 2) NULL,
    [points_in_eWallet]          DECIMAL (10, 2) NULL,
    [last_expired_evoucher]      DATETIME        NULL,
    [registered_phone_no]        VARCHAR (25)    NULL,
    [whatsapp_phone_no]          VARCHAR (25)    NULL,
    [diasbled_date]              DATETIME        NULL,
    [whatsapp_received_date]     VARCHAR (50)    NULL,
    [email_request_status]       VARCHAR (10)    NULL,
    [whatsapp_request_status]    VARCHAR (50)    NULL,
    [offender_status]            VARCHAR (50)    NULL,
    [reason]                     VARCHAR (4000)  NULL,
    [confiscated_status]         VARCHAR (50)    NULL,
    [confiscation_batch]         VARCHAR (50)    NULL,
    [filtering_status]           VARCHAR (255)   NULL,
    [unlocked_date]              VARCHAR (255)   NULL,
    [remark]                     VARCHAR (4000)  NULL,
    [created_at]                 DATETIME        NULL,
    [updated_at]                 DATETIME        NULL,
    [enquiry_received_date]      DATETIME        NULL,
    [confiscated_date]           DATETIME        NULL,
    [multiple_account_id]        VARCHAR (30)    NULL,
    [excel_id]                   INT             NULL,
    [Dev_team_name]              VARCHAR (100)   NULL,
    [Dev_team_action_date]       DATETIME        NULL,
    [Ops_manager_action_date]    DATETIME        NULL,
    [Ops_manager_name]           VARCHAR (50)    NULL,
    [Ops_staff_action_date]      DATETIME        NULL,
    [Ops_staff_name]             VARCHAR (50)    NULL,
    [Locked_by]                  VARCHAR (100)   NULL,
    [Customer_clarification]     VARCHAR (255)   NULL,
    [End_suspension_date]        VARCHAR (50)    NULL,
    [Ops_manager_remark]         VARCHAR (255)   NULL,
    [email_received_date]        DATETIME        NULL,
    [Final_approval_action_date] DATETIME        NULL,
    [Final_approval_name]        VARCHAR (100)   NULL,
    [Final_approval_remark]      VARCHAR (255)   NULL,
    [Final_approval_status]      VARCHAR (100)   NULL,
    [Locked_reason_updated_at]   DATETIME        NULL,
    [dev_team_action_status]     VARCHAR (100)   NULL,
    [ops_staff_action_status]    VARCHAR (100)   NULL,
    [ops_manager_action_status]  VARCHAR (100)   NULL,
    [case_close_date]            DATETIME        NULL,
    [lead_time]                  VARCHAR (100)   NULL,
    [case_open_date]             DATETIME        NULL,
    [Ops_manager_recommendation] VARCHAR (255)   NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

