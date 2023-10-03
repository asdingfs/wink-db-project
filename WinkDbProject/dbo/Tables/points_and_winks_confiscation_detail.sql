CREATE TABLE [dbo].[points_and_winks_confiscation_detail] (
    [id]                   INT             IDENTITY (1, 1) NOT NULL,
    [customer_id]          INT             NULL,
    [confiscated_points]   DECIMAL (10, 2) DEFAULT ((0)) NOT NULL,
    [confiscated_winks]    DECIMAL (10, 2) DEFAULT ((0)) NOT NULL,
    [total_winks]          DECIMAL (10, 2) DEFAULT ((0)) NOT NULL,
    [total_points]         DECIMAL (10, 2) DEFAULT ((0)) NOT NULL,
    [account_filtering_id] INT             DEFAULT ((0)) NOT NULL,
    [created_at]           DATETIME        NULL,
    [updated_at]           DATETIME        NULL,
    [confiscation_type]    VARCHAR (50)    NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

