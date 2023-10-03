CREATE TABLE [dbo].[campaign_log_old] (
    [Id]                   INT           NOT NULL,
    [action_id]            INT           NOT NULL,
    [campaign_id]          INT           NULL,
    [merchant_id]          INT           NULL,
    [campaign_amount]      DECIMAL (18)  NULL,
    [sales_code]           NVARCHAR (50) NULL,
    [total_winks]          DECIMAL (18)  NULL,
    [total_winks_amount]   DECIMAL (18)  NULL,
    [agency]               BIT           NULL,
    [agency_name]          NVARCHAR (50) NULL,
    [wink_purchase_only]   INT           NULL,
    [wink_purchase_status] NVARCHAR (50) NULL,
    [campaign_start_date]  DATETIME      NULL,
    [campaign_end_date]    DATETIME      NULL,
    [campaign_status]      BIT           NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

