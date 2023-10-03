CREATE TABLE [dbo].[points_confiscated_detail] (
    [id]                 INT      IDENTITY (1, 1) NOT NULL,
    [customer_id]        INT      NULL,
    [created_at]         DATETIME NULL,
    [updated_at]         DATETIME NULL,
    [confiscated_points] INT      NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

