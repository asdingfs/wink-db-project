CREATE TABLE [dbo].[TBL_WINKPLAY_WINKHUNT_CUSTOMER_CODES_LOG] (
    [WP_WH_CUST_CODES_LOG_ID] INT           IDENTITY (1, 1) NOT NULL,
    [ip_address]              VARCHAR (100) NULL,
    [location]                VARCHAR (250) NULL,
    [created_on]              DATETIME      NULL,
    [updated_on]              DATETIME      NULL,
    [customer_id]             INT           NOT NULL,
    [WP_WH_CODES_ID]          INT           NULL,
    PRIMARY KEY CLUSTERED ([WP_WH_CUST_CODES_LOG_ID] ASC),
    FOREIGN KEY ([WP_WH_CODES_ID]) REFERENCES [dbo].[TBL_WINKPLAY_WINKHUNT_CODES] ([WP_WH_CODES_ID])
);

