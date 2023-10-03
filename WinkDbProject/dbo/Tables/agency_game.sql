CREATE TABLE [dbo].[agency_game] (
    [id]            INT           IDENTITY (1, 1) NOT NULL,
    [agency_name]   VARCHAR (200) NULL,
    [group_size]    INT           NULL,
    [campaign_id]   INT           NULL,
    [created_at]    DATETIME      NULL,
    [team_id]       VARCHAR (20)  NULL,
    [team_name]     VARCHAR (50)  NULL,
    [agency_status] INT           DEFAULT ((0)) NOT NULL,
    [agency_code]   VARCHAR (10)  NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

