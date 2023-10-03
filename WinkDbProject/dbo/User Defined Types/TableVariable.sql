CREATE TYPE [dbo].[TableVariable] AS TABLE (
    [id]          INT           NULL,
    [team_id]     INT           NOT NULL,
    [customer_id] INT           NOT NULL,
    [email]       VARCHAR (255) NOT NULL,
    [first_name]  VARCHAR (255) NOT NULL,
    [last_name]   VARCHAR (255) NOT NULL);

