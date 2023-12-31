﻿CREATE TABLE [dbo].[customer_backup_popo] (
    [customer_id]               INT           IDENTITY (1, 1) NOT NULL,
    [first_name]                VARCHAR (100) NOT NULL,
    [last_name]                 VARCHAR (100) NOT NULL,
    [email]                     VARCHAR (200) NOT NULL,
    [password]                  VARCHAR (200) NOT NULL,
    [gender]                    NCHAR (10)    NULL,
    [date_of_birth]             VARCHAR (100) NULL,
    [auth_token]                VARCHAR (200) NOT NULL,
    [created_at]                DATETIME      NULL,
    [updated_at]                DATETIME      NULL,
    [imob_customer_id]          INT           DEFAULT ((0)) NOT NULL,
    [phone_no]                  VARCHAR (10)  NULL,
    [status]                    VARCHAR (10)  DEFAULT ('enable') NOT NULL,
    [group_id]                  VARCHAR (10)  DEFAULT ((1)) NOT NULL,
    [confiscated_wink_status]   VARCHAR (10)  DEFAULT ((0)) NOT NULL,
    [subscribe_status]          VARCHAR (10)  DEFAULT ((0)) NOT NULL,
    [confiscated_points_status] VARCHAR (1)   NULL,
    [sign_in_status]            INT           DEFAULT ((0)) NOT NULL,
    [customer_password]         VARCHAR (50)  NULL,
    [avatar_id]                 INT           DEFAULT ((1)) NOT NULL,
    [avatar_image]              VARCHAR (250) NULL,
    [ip_address]                VARCHAR (50)  NULL,
    [ip_scanned]                VARCHAR (50)  NULL,
    [skin_name]                 VARCHAR (50)  DEFAULT ('pink') NOT NULL,
    [team_id]                   INT           DEFAULT ((1)) NOT NULL,
    [nick_name]                 VARCHAR (30)  NULL,
    [updated_password_date]     DATETIME      NULL,
    [customer_unique_id]        VARCHAR (200) NULL,
    PRIMARY KEY CLUSTERED ([customer_id] ASC),
    UNIQUE NONCLUSTERED ([auth_token] ASC),
    UNIQUE NONCLUSTERED ([auth_token] ASC),
    UNIQUE NONCLUSTERED ([email] ASC),
    UNIQUE NONCLUSTERED ([email] ASC)
);

