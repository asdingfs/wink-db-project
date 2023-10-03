CREATE TABLE [dbo].[team] (
    [team_id]       INT           IDENTITY (1, 1) NOT NULL,
    [team_name]     VARCHAR (255) NOT NULL,
    [event_date_id] INT           NOT NULL,
    [invoice_id]    INT           NOT NULL,
    [active_status] BIT           NOT NULL,
    [created_date]  DATETIME      NULL,
    [updated_date]  DATETIME      NULL
);

