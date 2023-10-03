CREATE TABLE [dbo].[nonstop_net_canid_earned_points2] (
    [id]                    INT             IDENTITY (1, 1) NOT NULL,
    [can_id]                VARCHAR (50)    NOT NULL,
    [business_date]         DATETIME        NOT NULL,
    [total_tabs]            INT             DEFAULT ((1)) NOT NULL,
    [total_points]          DECIMAL (10, 2) DEFAULT ((0)) NOT NULL,
    [created_at]            DATETIME        NULL,
    [customer_id]           INT             NOT NULL,
    [card_type]             VARCHAR (50)    DEFAULT ('all') NOT NULL,
    [net_promotion_id]      INT             DEFAULT ((0)) NOT NULL,
    [points_credit_status]  INT             DEFAULT ((0)) NOT NULL,
    [point_redemption_date] DATETIME        NULL,
    [trans_amount]          DECIMAL (10, 2) DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

