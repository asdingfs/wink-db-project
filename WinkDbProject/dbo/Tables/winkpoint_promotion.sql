CREATE TABLE [dbo].[winkpoint_promotion] (
    [event_id]         INT             IDENTITY (1, 1) NOT NULL,
    [event_name]       VARCHAR (200)   NULL,
    [event_start_date] DATETIME        NULL,
    [event_end_date]   DATETIME        NULL,
    [total_quantity]   INT             NULL,
    [points]           DECIMAL (10, 2) NULL,
    [image_name]       VARCHAR (200)   NULL,
    [redeemed_points]  DECIMAL (10, 2) DEFAULT ((0)) NULL,
    [redeemed_qty]     INT             DEFAULT ((0)) NULL,
    [created_at]       DATETIME        NULL,
    [event_status]     VARCHAR (10)    DEFAULT ('1') NOT NULL,
    [total_points]     INT             DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([event_id] ASC)
);

