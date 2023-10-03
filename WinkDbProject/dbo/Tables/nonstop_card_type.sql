CREATE TABLE [dbo].[nonstop_card_type] (
    [id]          INT          IDENTITY (1, 1) NOT NULL,
    [card_type]   VARCHAR (30) NULL,
    [card_code]   VARCHAR (50) NULL,
    [created_at]  DATETIME     NULL,
    [campaign_id] INT          NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

