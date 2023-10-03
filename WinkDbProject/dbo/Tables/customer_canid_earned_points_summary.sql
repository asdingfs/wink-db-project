CREATE TABLE [dbo].[customer_canid_earned_points_summary] (
    [id]           INT             IDENTITY (1, 1) NOT NULL,
    [can_id]       VARCHAR (50)    NOT NULL,
    [total_points] DECIMAL (10, 2) DEFAULT ((0)) NOT NULL,
    [created_at]   DATETIME        NOT NULL,
    [total_tabs]   INT             DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

