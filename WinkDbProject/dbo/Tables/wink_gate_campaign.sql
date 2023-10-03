CREATE TABLE [dbo].[wink_gate_campaign] (
    [id]           INT      IDENTITY (1, 1) NOT NULL,
    [campaign_id]  INT      NULL,
    [total_points] INT      NULL,
    [status]       INT      NULL,
    [updated_at]   DATETIME NOT NULL,
    [created_at]   DATETIME NOT NULL,
    CONSTRAINT [PK_wink_gate_campaign] PRIMARY KEY CLUSTERED ([id] ASC)
);

