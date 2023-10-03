CREATE TABLE [dbo].[rate_conversion] (
    [rate_conversion_name] VARCHAR (100)   NULL,
    [created_at]           DATETIME        NULL,
    [updated_at]           DATETIME        NULL,
    [rate_value]           DECIMAL (10, 2) NULL,
    [rate_conversion_id]   INT             IDENTITY (1, 1) NOT NULL,
    [rate_code]            VARCHAR (100)   NOT NULL,
    PRIMARY KEY CLUSTERED ([rate_conversion_id] ASC)
);

