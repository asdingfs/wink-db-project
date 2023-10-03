CREATE TABLE [dbo].[merchant] (
    [merchant_id]          INT           IDENTITY (1, 1) NOT NULL,
    [first_name]           VARCHAR (200) NOT NULL,
    [last_name]            VARCHAR (100) NULL,
    [email]                VARCHAR (100) NOT NULL,
    [password]             VARCHAR (100) NULL,
    [mas_code]             VARCHAR (100) NULL,
    [created_at]           DATETIME      NULL,
    [updated_at]           DATETIME      NULL,
    [allowed_used_device]  BIT           CONSTRAINT [DF__merchant__allowe__6EC0713C] DEFAULT ((0)) NULL,
    [imobshop_merchant_id] INT           CONSTRAINT [DF__merchant__imobsh__6FB49575] DEFAULT ((0)) NULL,
    [auth_token]           VARCHAR (50)  NULL,
    [wink_fee_percent]     INT           CONSTRAINT [DF_merchant_wink_fee_percent] DEFAULT ((0)) NULL,
    [status]               VARCHAR (10)  CONSTRAINT [DF__merchant__status__06ED0088] DEFAULT ('enable') NULL,
    CONSTRAINT [PK__merchant__02BC30BA7C9160FF] PRIMARY KEY CLUSTERED ([merchant_id] ASC)
);

