CREATE TABLE [dbo].[customer_action_log_summary_no_register] (
    [id]                   INT          IDENTITY (1, 1) NOT NULL,
    [customer_id]          INT          NULL,
    [customer_action_date] VARCHAR (20) NULL,
    [created]              DATETIME     NULL
);

