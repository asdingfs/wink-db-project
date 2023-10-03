CREATE TYPE [dbo].[GameTableVariableUpdate] AS TABLE (
    [customer_id]    INT           NOT NULL,
    [email]          VARCHAR (255) NOT NULL,
    [first_name]     VARCHAR (255) NOT NULL,
    [last_name]      VARCHAR (255) NOT NULL,
    [team_player_id] INT           NOT NULL);

