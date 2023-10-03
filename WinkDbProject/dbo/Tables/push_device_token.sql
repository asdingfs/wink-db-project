CREATE TABLE [dbo].[push_device_token] (
    [id]            INT           IDENTITY (1, 1) NOT NULL,
    [device_token]  VARCHAR (MAX) NOT NULL,
    [customer_id]   VARCHAR (50)  NULL,
    [WID]           VARCHAR (50)  NULL,
    [device_type]   VARCHAR (50)  NOT NULL,
    [app_version]   VARCHAR (50)  NULL,
    [active_status] VARCHAR (10)  CONSTRAINT [DF__push_devi__activ__47F18835] DEFAULT ((0)) NULL,
    [created_at]    DATETIME      NOT NULL,
    [updated_at]    DATETIME      NOT NULL
);

