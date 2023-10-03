CREATE TABLE [dbo].[master_user_group_relationship] (
    [id]              INT          IDENTITY (1, 1) NOT NULL,
    [master_group_id] INT          NOT NULL,
    [email]           VARCHAR (50) NOT NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

