CREATE TABLE [dbo].[nets_sponsor_points] (
    [id]           INT             IDENTITY (1, 1) NOT NULL,
    [total_points] DECIMAL (10, 2) NULL,
    [created_at]   DATETIME        NULL,
    [updated_at]   DATETIME        NULL,
    [from_date]    DATETIME        NULL,
    [to_date]      DATETIME        NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

