CREATE TABLE [dbo].[lock_ip16_log] (
    [id]        INT           IDENTITY (1, 1) NOT NULL,
    [action_id] INT           NOT NULL,
    [ipList]    VARCHAR (MAX) NOT NULL,
    [createdAt] DATETIME      NOT NULL,
    [updatedAt] DATETIME      NOT NULL,
    CONSTRAINT [PK_lock_ip16_log] PRIMARY KEY CLUSTERED ([id] ASC)
);

