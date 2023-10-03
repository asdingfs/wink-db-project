﻿CREATE TABLE [dbo].[wink_canid_earned_points_chuned_customer] (
    [id]            INT          IDENTITY (1, 1) NOT NULL,
    [can_id]        VARCHAR (50) DEFAULT ((0)) NOT NULL,
    [business_date] DATETIME     NOT NULL,
    [total_tabs]    INT          DEFAULT ((0)) NOT NULL,
    [total_points]  INT          DEFAULT ((0)) NOT NULL,
    [created_at]    DATETIME     NULL,
    [customer_id]   INT          DEFAULT ((0)) NULL,
    [churned_from]  VARCHAR (10) DEFAULT ('others') NOT NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

