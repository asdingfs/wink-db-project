CREATE TABLE [dbo].[game_arena_log] (
    [arena_log_id] INT          IDENTITY (1, 1) NOT NULL,
    [arena_id]     INT          NOT NULL,
    [player_id]    INT          NOT NULL,
    [customer_id]  INT          NOT NULL,
    [status]       VARCHAR (10) NOT NULL,
    [created_at]   DATETIME     NULL,
    [updated_at]   DATETIME     NULL
);

