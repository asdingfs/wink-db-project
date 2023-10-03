CREATE TABLE [dbo].[posthirdparty_redemption_log] (
    [id]                INT           IDENTITY (1, 1) NOT NULL,
    [response_message]  VARCHAR (255) NULL,
    [merchant_key]      VARCHAR (255) NULL,
    [merchant_id]       VARCHAR (255) NULL,
    [created_at]        DATETIME      NULL,
    [updated_at]        DATETIME      NULL,
    [verification_code] VARCHAR (50)  NULL,
    [merchant_name]     VARCHAR (255) NULL,
    [action_api]        VARCHAR (255) NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

