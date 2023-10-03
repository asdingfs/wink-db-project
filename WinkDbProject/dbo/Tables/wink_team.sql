CREATE TABLE [dbo].[wink_team] (
    [team_id]     INT           IDENTITY (1, 1) NOT NULL,
    [team_name]   VARCHAR (100) NULL,
    [team_status] VARCHAR (10)  DEFAULT ('enable') NOT NULL,
    [created_at]  DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([team_id] ASC)
);

