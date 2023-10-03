CREATE TABLE [dbo].[wink_game_session] (
    [id]          INT           IDENTITY (1, 1) NOT NULL,
    [campaign_id] INT           NULL,
    [asset_name]  VARCHAR (100) NOT NULL,
    [pin]         INT           NOT NULL,
    [created_at]  DATETIME      NOT NULL,
    [expired_at]  DATETIME      NOT NULL,
    CONSTRAINT [PK_screen_session] PRIMARY KEY CLUSTERED ([id] ASC)
);

