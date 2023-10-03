CREATE TABLE [dbo].[winners_points] (
    [id]          INT           IDENTITY (1, 1) NOT NULL,
    [entry_id]    INT           NOT NULL,
    [customer_id] INT           NOT NULL,
    [points]      INT           NOT NULL,
    [location]    VARCHAR (150) NULL,
    [created_at]  DATETIME      NOT NULL,
    CONSTRAINT [PK_winners_points] PRIMARY KEY CLUSTERED ([id] ASC)
);

