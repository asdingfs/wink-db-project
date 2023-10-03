CREATE TABLE [dbo].[game_challenge_points] (
    [id]          INT          IDENTITY (1, 1) NOT NULL,
    [customer_id] INT          NOT NULL,
    [player_id]   INT          NOT NULL,
    [arena_id]    INT          NOT NULL,
    [battle_id]   INT          NOT NULL,
    [status]      VARCHAR (10) NOT NULL,
    [points]      DECIMAL (18) NOT NULL,
    [created_at]  DATETIME     NULL,
    [updated_at]  DATETIME     NULL
);

