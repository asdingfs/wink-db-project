CREATE TABLE [dbo].[customer_earned_points_by_event] (
    [id]          INT          IDENTITY (1, 1) NOT NULL,
    [customer_id] INT          NULL,
    [points]      INT          DEFAULT ((0)) NOT NULL,
    [event_name]  VARCHAR (20) NULL,
    [created_at]  DATETIME     NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

