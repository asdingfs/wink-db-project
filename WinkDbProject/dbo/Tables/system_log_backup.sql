﻿CREATE TABLE [dbo].[system_log_backup] (
    [id]            INT           IDENTITY (1, 1) NOT NULL,
    [customer_id]   INT           NULL,
    [action_status] VARCHAR (50)  NULL,
    [created_at]    DATETIME      NULL,
    [reason]        VARCHAR (200) NULL,
    [enable_status] VARCHAR (10)  NOT NULL,
    [enable_date]   DATETIME      NULL,
    [WID]           VARCHAR (50)  NULL,
    [device_token]  VARCHAR (255) NULL,
    [device_type]   VARCHAR (50)  NULL
);

