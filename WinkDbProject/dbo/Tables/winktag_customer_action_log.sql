CREATE TABLE [dbo].[winktag_customer_action_log] (
    [id]                     INT           IDENTITY (1, 1) NOT NULL,
    [customer_id]            INT           NULL,
    [campaign_id]            INT           NULL,
    [customer_action]        VARCHAR (50)  NULL,
    [ip_address]             VARCHAR (100) NULL,
    [location]               VARCHAR (250) NULL,
    [created_at]             DATETIME      NULL,
    [survey_complete_status] BIT           DEFAULT ((0)) NULL
);

