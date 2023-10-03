CREATE TABLE [dbo].[event_date] (
    [event_date_id] INT           IDENTITY (1, 1) NOT NULL,
    [event_date]    VARCHAR (255) NOT NULL,
    [created_date]  DATETIME      NULL,
    [updated_date]  DATETIME      NULL
);

