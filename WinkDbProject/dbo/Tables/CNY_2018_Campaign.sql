CREATE TABLE [dbo].[CNY_2018_Campaign] (
    [id]                    INT           IDENTITY (1, 1) NOT NULL,
    [campaign_id]           INT           NULL,
    [customer_id]           INT           NULL,
    [answer]                VARCHAR (150) NULL,
    [correct_answer_status] VARCHAR (10)  DEFAULT ('No') NOT NULL,
    [created_at]            DATETIME      NULL,
    [updated_at]            DATETIME      NULL,
    [ip_address]            VARCHAR (25)  NULL,
    [location]              VARCHAR (100) NULL,
    [new_user_status]       INT           DEFAULT ((0)) NOT NULL,
    [points_rewards]        INT           DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

