CREATE TABLE [dbo].[game_take_over_points] (
    [id]          INT          IDENTITY (1, 1) NOT NULL,
    [customer_id] INT          NOT NULL,
    [player_id]   INT          NOT NULL,
    [arena_id]    INT          NOT NULL,
    [points]      DECIMAL (18) NOT NULL,
    [created_at]  DATETIME     NULL,
    [updated_at]  DATETIME     NULL
);

