CREATE TABLE [dbo].[wink_net_canid_earned_points] (
    [id]                   INT             IDENTITY (1, 1) NOT NULL,
    [can_id]               VARCHAR (50)    DEFAULT ((0)) NOT NULL,
    [business_date]        DATETIME        NOT NULL,
    [total_tabs]           INT             DEFAULT ((0)) NOT NULL,
    [total_points]         DECIMAL (10, 2) DEFAULT ((0.00)) NOT NULL,
    [created_at]           DATETIME        NULL,
    [customer_id]          INT             DEFAULT ((0)) NOT NULL,
    [card_type]            VARCHAR (50)    DEFAULT ('all') NOT NULL,
    [promotion_id]         INT             DEFAULT ((1)) NOT NULL,
    [points_credit_status] INT             DEFAULT ((0)) NOT NULL,
    [promotion_name]       VARCHAR (50)    NULL,
    [location]             VARCHAR (200)   NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

