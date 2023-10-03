CREATE TABLE [dbo].[wink_treasure_winner] (
    [winner_id]         INT          IDENTITY (1, 1) NOT NULL,
    [customer_id]       INT          NULL,
    [winner_prize_id]   INT          NULL,
    [created_at]        DATETIME     NULL,
    [redemption_status] VARCHAR (10) DEFAULT ((0)) NOT NULL,
    [nric]              VARCHAR (20) NULL,
    [event_name]        VARCHAR (30) NULL,
    [redemption_type]   VARCHAR (30) NULL,
    PRIMARY KEY CLUSTERED ([winner_id] ASC)
);

