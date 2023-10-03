CREATE TABLE [dbo].[nonstop_net_canid_earned_points] (
    [id]                         INT             IDENTITY (1, 1) NOT NULL,
    [can_id]                     VARCHAR (50)    NOT NULL,
    [business_date]              DATETIME        NOT NULL,
    [total_tabs]                 INT             CONSTRAINT [DF__nonstop_n__total__6E2C3FB6] DEFAULT ((1)) NOT NULL,
    [total_points]               DECIMAL (10, 2) CONSTRAINT [DF__nonstop_n__total__6F2063EF] DEFAULT ((0)) NOT NULL,
    [created_at]                 DATETIME        NULL,
    [customer_id]                INT             NOT NULL,
    [card_type]                  VARCHAR (50)    CONSTRAINT [DF__nonstop_n__card___70148828] DEFAULT ('all') NOT NULL,
    [points_credit_status]       INT             CONSTRAINT [DF__nonstop_n__point__71FCD09A] DEFAULT ((0)) NOT NULL,
    [point_redemption_date]      DATETIME        NULL,
    [trans_amount]               DECIMAL (10, 2) CONSTRAINT [DF__nonstop_n__trans__6561EF8B] DEFAULT ((0)) NOT NULL,
    [updated_at]                 DATETIME        NULL,
    [gps_location]               VARCHAR (200)   NULL,
    [points_expired_status]      VARCHAR (10)    CONSTRAINT [DF__nonstop_n__point__2453463D] DEFAULT ((0)) NOT NULL,
    [campaign_id]                INT             NULL,
    [wink_gate_asset_id]         INT             NULL,
    [ip_address]                 VARCHAR (30)    NULL,
    [wink_gate_points_earned_id] INT             NULL,
    CONSTRAINT [PK__nonstop___3213E83FC277FC30] PRIMARY KEY CLUSTERED ([id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_nonstop_net_canid_earned_points]
    ON [dbo].[nonstop_net_canid_earned_points]([customer_id] ASC, [created_at] ASC, [points_credit_status] ASC, [card_type] ASC);

