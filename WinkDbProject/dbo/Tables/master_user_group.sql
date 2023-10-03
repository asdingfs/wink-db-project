CREATE TABLE [dbo].[master_user_group] (
    [id]                INT          IDENTITY (1, 1) NOT NULL,
    [master_group_name] VARCHAR (50) NOT NULL,
    [master_group_id]   INT          NOT NULL,
    PRIMARY KEY CLUSTERED ([id] ASC),
    UNIQUE NONCLUSTERED ([master_group_id] ASC),
    UNIQUE NONCLUSTERED ([master_group_id] ASC)
);

