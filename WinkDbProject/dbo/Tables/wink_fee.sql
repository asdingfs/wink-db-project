CREATE TABLE [dbo].[wink_fee] (
    [id]              INT             IDENTITY (1, 1) NOT NULL,
    [wink_fee_key]    VARCHAR (100)   NULL,
    [wink_fee_value]  DECIMAL (10, 2) NULL,
    [name]            VARCHAR (255)   NULL,
    [rate_type]       VARCHAR (50)    NULL,
    [wink_fee_status] INT             DEFAULT ((1)) NOT NULL,
    [created_at]      DATETIME        NULL,
    [updated_at]      DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

