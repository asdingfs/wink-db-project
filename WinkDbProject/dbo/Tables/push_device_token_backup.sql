CREATE TABLE [dbo].[push_device_token_backup] (
    [id]            INT           IDENTITY (1, 1) NOT NULL,
    [device_token]  VARCHAR (255) NOT NULL,
    [customer_id]   VARCHAR (50)  NULL,
    [WID]           VARCHAR (50)  NULL,
    [device_type]   VARCHAR (50)  NOT NULL,
    [active_status] VARCHAR (10)  DEFAULT ((0)) NULL,
    [created_at]    DATETIME      NOT NULL,
    [updated_at]    DATETIME      NOT NULL
);

