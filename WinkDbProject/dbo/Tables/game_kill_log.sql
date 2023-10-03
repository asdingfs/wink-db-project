CREATE TABLE [dbo].[game_kill_log] (
    [id]                 INT          IDENTITY (1, 1) NOT NULL,
    [arena_log_id]       INT          NOT NULL,
    [arena_id]           INT          NOT NULL,
    [killer_player_id]   INT          NOT NULL,
    [killer_customer_id] INT          NOT NULL,
    [battle_id]          INT          NOT NULL,
    [type]               VARCHAR (50) NOT NULL,
    [created_at]         DATETIME     NULL,
    [updated_at]         DATETIME     NULL
);

