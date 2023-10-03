CREATE TABLE [dbo].[game_team_players_details] (
    [team_player_id] INT           IDENTITY (1, 1) NOT NULL,
    [team_id]        INT           NOT NULL,
    [event_date_id]  INT           NOT NULL,
    [customer_id]    INT           NOT NULL,
    [email]          VARCHAR (255) NULL,
    [first_name]     VARCHAR (255) NOT NULL,
    [last_name]      VARCHAR (255) NOT NULL,
    [active_status]  BIT           NOT NULL,
    [created_date]   DATETIME      NULL,
    [updated_date]   DATETIME      NULL
);

