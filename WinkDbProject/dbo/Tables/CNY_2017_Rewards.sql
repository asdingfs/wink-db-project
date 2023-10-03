CREATE TABLE [dbo].[CNY_2017_Rewards] (
    [created_at]         DATETIME     NULL,
    [reward_id]          INT          IDENTITY (1, 1) NOT NULL,
    [customer_id]        INT          DEFAULT ((0)) NOT NULL,
    [event_name]         VARCHAR (30) NULL,
    [total_facebook_tag] INT          DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([reward_id] ASC)
);

