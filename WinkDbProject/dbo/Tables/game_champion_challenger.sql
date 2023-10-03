CREATE TABLE [dbo].[game_champion_challenger] (
    [id]                     INT          IDENTITY (1, 1) NOT NULL,
    [battle_id]              INT          NOT NULL,
    [arena_id]               INT          NOT NULL,
    [arena_log_id]           INT          NOT NULL,
    [champion_player_id]     INT          NOT NULL,
    [champion_customer_id]   INT          NOT NULL,
    [champion_animal_id]     INT          NOT NULL,
    [challenger_player_id]   INT          NOT NULL,
    [challenger_customer_id] INT          NOT NULL,
    [challenger_animal_id]   INT          NOT NULL,
    [winner_id]              INT          NOT NULL,
    [challenge_points]       DECIMAL (18) NOT NULL,
    [created_at]             DATETIME     NULL,
    [updated_at]             DATETIME     NULL
);

