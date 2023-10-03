CREATE TABLE [dbo].[agency_game_customers] (
    [id]                       INT          IDENTITY (1, 1) NOT NULL,
    [phone_no]                 VARCHAR (20) NULL,
    [group_id]                 INT          NULL,
    [created_at]               DATETIME     NULL,
    [total_confiscated_scan]   INT          DEFAULT ((0)) NOT NULL,
    [total_confiscated_points] INT          DEFAULT ((0)) NOT NULL,
    [customer_id]              INT          NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

