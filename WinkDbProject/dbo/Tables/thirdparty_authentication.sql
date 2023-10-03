CREATE TABLE [dbo].[thirdparty_authentication] (
    [id]             INT           IDENTITY (1, 1) NOT NULL,
    [merchant_id]    INT           DEFAULT ((0)) NOT NULL,
    [merchant_email] VARCHAR (100) NULL,
    [secret_key]     VARCHAR (255) NULL,
    [created_at]     DATETIME      NULL,
    [updated_at]     DATETIME      NULL,
    [status_auth]    BIT           DEFAULT ((1)) NULL,
    [merchant_name]  VARCHAR (200) NULL,
    PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [Uniquesecretkey] UNIQUE NONCLUSTERED ([secret_key] ASC)
);

