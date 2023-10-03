CREATE TABLE [dbo].[game_player_milestone_complete] (
    [id]               INT      IDENTITY (1, 1) NOT NULL,
    [team_id]          INT      NULL,
    [milestone_number] INT      DEFAULT ((0)) NOT NULL,
    [created_at]       DATETIME NULL,
    [event_id]         INT      NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

