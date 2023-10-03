CREATE TABLE [dbo].[winktag_customer_earned_points] (
    [id]                      INT           IDENTITY (1, 1) NOT NULL,
    [campaign_id]             INT           NOT NULL,
    [question_id]             INT           DEFAULT ((0)) NULL,
    [customer_id]             INT           NOT NULL,
    [points]                  INT           DEFAULT ((0)) NOT NULL,
    [GPS_location]            VARCHAR (200) NULL,
    [ip_address]              VARCHAR (30)  NULL,
    [created_at]              DATETIME      NULL,
    [row_count]               INT           DEFAULT ((1)) NULL,
    [additional_point_status] BIT           DEFAULT ((0)) NOT NULL
);

