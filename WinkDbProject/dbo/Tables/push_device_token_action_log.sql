CREATE TABLE [dbo].[push_device_token_action_log] (
    [id]              INT           IDENTITY (1, 1) NOT NULL,
    [device_token]    VARCHAR (255) NOT NULL,
    [customer_id]     VARCHAR (50)  NULL,
    [WID]             VARCHAR (50)  NULL,
    [device_type]     VARCHAR (50)  NOT NULL,
    [app_version]     VARCHAR (50)  NULL,
    [customer_action] VARCHAR (50)  NOT NULL,
    [created_at]      DATETIME      NOT NULL,
    [updated_at]      DATETIME      NOT NULL
);

