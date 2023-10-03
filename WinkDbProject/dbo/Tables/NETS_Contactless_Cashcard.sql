CREATE TABLE [dbo].[NETS_Contactless_Cashcard] (
    [id]                       INT           IDENTITY (1, 1) NOT NULL,
    [campaign_id]              INT           NULL,
    [customer_id]              INT           NULL,
    [points_rewards]           INT           NOT NULL,
    [correct_answer_status]    VARCHAR (10)  NOT NULL,
    [nets_card]                VARCHAR (50)  NULL,
    [registered_date_for_nets] DATETIME      NULL,
    [created_at]               DATETIME      NULL,
    [updated_at]               DATETIME      NULL,
    [ip_address]               VARCHAR (25)  NULL,
    [location]                 VARCHAR (100) NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

