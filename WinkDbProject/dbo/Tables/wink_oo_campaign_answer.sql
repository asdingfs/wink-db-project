CREATE TABLE [dbo].[wink_oo_campaign_answer] (
    [id]            INT          IDENTITY (1, 1) NOT NULL,
    [campaign_id]   INT          NULL,
    [answer]        VARCHAR (30) NULL,
    [answer_status] INT          DEFAULT ((0)) NULL,
    [created_at]    DATETIME     NULL,
    [updated_at]    DATETIME     NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

