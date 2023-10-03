CREATE TABLE [dbo].[pts_issuance_data_log] (
    [id]            INT           IDENTITY (1, 1) NOT NULL,
    [action_id]     INT           NULL,
    [campaign_id]   INT           NULL,
    [campaign_name] VARCHAR (250) NULL,
    CONSTRAINT [PK_pts_issuance_campaign_data_log] PRIMARY KEY CLUSTERED ([id] ASC)
);

