CREATE TABLE [dbo].[duplicate_normalisation_log] (
    [id]         INT      IDENTITY (1, 1) NOT NULL,
    [action_id]  INT      NOT NULL,
    [targetDate] DATETIME NOT NULL,
    [createdAt]  DATETIME NOT NULL,
    CONSTRAINT [PK_duplicate_normalisation_log] PRIMARY KEY CLUSTERED ([id] ASC)
);

