CREATE TABLE [dbo].[game_checkpoint_details_bylocation] (
    [checkpoint_id] INT           IDENTITY (1, 1) NOT NULL,
    [qr_code]       VARCHAR (255) NOT NULL,
    [location_id]   INT           NOT NULL,
    [location]      VARCHAR (255) NOT NULL,
    [event_id]      INT           NOT NULL,
    [event_date_id] INT           NOT NULL,
    [event_date]    VARCHAR (255) NOT NULL,
    [created_date]  DATETIME      NULL,
    [updated_date]  DATETIME      NULL
);

