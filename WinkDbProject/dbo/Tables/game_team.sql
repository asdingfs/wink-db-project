CREATE TABLE [dbo].[game_team] (
    [team_id]       INT           IDENTITY (1, 1) NOT NULL,
    [team_name]     VARCHAR (255) NOT NULL,
    [event_date_id] INT           NOT NULL,
    [event_date]    VARCHAR (255) NOT NULL,
    [invoice_id]    VARCHAR (255) NOT NULL,
    [active_status] BIT           NOT NULL,
    [created_date]  DATETIME      NULL,
    [updated_date]  DATETIME      NULL,
    UNIQUE NONCLUSTERED ([team_name] ASC)
);

