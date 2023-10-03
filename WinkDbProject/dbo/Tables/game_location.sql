CREATE TABLE [dbo].[game_location] (
    [location_id]   INT           IDENTITY (1, 1) NOT NULL,
    [location]      VARCHAR (255) NOT NULL,
    [event_date_id] INT           NOT NULL,
    [created_date]  DATETIME      NULL,
    [updated_date]  DATETIME      NULL
);

