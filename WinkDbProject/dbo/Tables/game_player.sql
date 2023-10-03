CREATE TABLE [dbo].[game_player] (
    [player_id]      INT           IDENTITY (1, 1) NOT NULL,
    [customer_id]    INT           NOT NULL,
    [customer_token] VARCHAR (200) NOT NULL,
    [arena_id]       INT           NOT NULL,
    [status]         VARCHAR (10)  NOT NULL,
    [created_at]     DATETIME      NULL,
    [updated_at]     DATETIME      NULL
);

