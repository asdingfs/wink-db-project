CREATE TABLE [dbo].[event_winner] (
    [id]          INT           IDENTITY (1, 1) NOT NULL,
    [customer_id] INT           NULL,
    [email]       VARCHAR (200) NULL,
    [event_name]  VARCHAR (100) NULL,
    [created_at]  DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

