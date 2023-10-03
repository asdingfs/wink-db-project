CREATE TABLE [dbo].[agency_game_dailytop_scanner] (
    [id]           INT          IDENTITY (1, 1) NOT NULL,
    [customer_id]  INT          NULL,
    [created_at]   DATETIME     NULL,
    [total_scans]  INT          NULL,
    [total_points] INT          NULL,
    [phone_no]     VARCHAR (10) NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

