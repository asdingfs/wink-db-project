CREATE TABLE [dbo].[game_arena] (
    [arena_id]    INT           IDENTITY (1, 1) NOT NULL,
    [arena_name]  VARCHAR (255) NOT NULL,
    [entry-fee]   DECIMAL (18)  NOT NULL,
    [arena_bonus] DECIMAL (18)  NOT NULL,
    [no_of_kill]  INT           DEFAULT ((0)) NULL,
    [status]      VARCHAR (10)  NOT NULL,
    [created_at]  DATETIME      NULL,
    [updated_at]  DATETIME      NULL
);

