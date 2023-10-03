CREATE TABLE [dbo].[wink_fee_new_data_log] (
    [id]             INT             IDENTITY (1, 1) NOT NULL,
    [wink_fee_key]   VARCHAR (100)   NULL,
    [wink_fee_value] DECIMAL (10, 2) NULL,
    [name]           VARCHAR (255)   NULL,
    [rate_type]      VARCHAR (50)    NULL,
    [action_id]      INT             NULL,
    [created_at]     DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

