CREATE TABLE [dbo].[push_device_token_android_backup] (
    [id]           INT           IDENTITY (1, 1) NOT NULL,
    [device_token] VARCHAR (255) NOT NULL,
    [customer_id]  INT           NULL,
    [created_at]   DATETIME      NULL,
    [updated_at]   DATETIME      NULL
);

