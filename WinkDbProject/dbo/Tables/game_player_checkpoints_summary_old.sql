CREATE TABLE [dbo].[game_player_checkpoints_summary_old] (
    [id]         INT           IDENTITY (1, 1) NOT NULL,
    [team_id]    INT           NULL,
    [qr_code]    VARCHAR (100) NULL,
    [created_at] DATETIME      NULL,
    [event_id]   INT           NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

