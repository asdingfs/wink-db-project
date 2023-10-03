CREATE TABLE [dbo].[gate_campaign_old_data_log] (
    [id]                    INT           IDENTITY (1, 1) NOT NULL,
    [action_id]             INT           NULL,
    [wink_gate_campaign_id] INT           NULL,
    [campaign_name]         VARCHAR (500) NULL,
    [old_total_points]      INT           NULL,
    [start_date]            DATETIME      NULL,
    [end_date]              DATETIME      NULL,
    [old_status]            INT           NULL,
    CONSTRAINT [PK_gate_campaign_old_data_log_1] PRIMARY KEY CLUSTERED ([id] ASC)
);

