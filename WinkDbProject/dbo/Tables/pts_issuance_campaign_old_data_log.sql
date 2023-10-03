CREATE TABLE [dbo].[pts_issuance_campaign_old_data_log] (
    [id]                INT           IDENTITY (1, 1) NOT NULL,
    [action_id]         INT           NULL,
    [campaign_id]       INT           NULL,
    [old_campaign_name] VARCHAR (250) NULL,
    [old_points]        INT           NULL,
    CONSTRAINT [PK_pts_issuance_campaign_old_data_log] PRIMARY KEY CLUSTERED ([id] ASC)
);

