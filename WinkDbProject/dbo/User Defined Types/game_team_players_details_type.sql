CREATE TYPE [dbo].[game_team_players_details_type] AS TABLE (
    [team_id]     INT           NOT NULL,
    [customer_id] INT           NOT NULL,
    [email]       VARCHAR (255) NOT NULL,
    [first_name]  VARCHAR (255) NOT NULL,
    [last_name]   VARCHAR (255) NOT NULL);

