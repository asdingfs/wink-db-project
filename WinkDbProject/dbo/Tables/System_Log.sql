CREATE TABLE [dbo].[System_Log] (
    [id]            INT           IDENTITY (1, 1) NOT NULL,
    [customer_id]   INT           NULL,
    [action_status] VARCHAR (50)  NULL,
    [created_at]    DATETIME      NULL,
    [reason]        VARCHAR (200) NULL,
    [enable_status] VARCHAR (10)  DEFAULT ('No') NOT NULL,
    [enable_date]   DATETIME      NULL,
    [device_token]  VARCHAR (255) NULL,
    [device_type]   VARCHAR (50)  NULL,
    [locked_desc]   VARCHAR (255) NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

