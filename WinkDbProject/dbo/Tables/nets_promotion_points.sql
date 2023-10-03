CREATE TABLE [dbo].[nets_promotion_points] (
    [id]             INT             IDENTITY (1, 1) NOT NULL,
    [total_points]   DECIMAL (10, 2) NULL,
    [created_at]     DATETIME        NULL,
    [updated_at]     DATETIME        NULL,
    [from_date]      DATETIME        NULL,
    [to_date]        DATETIME        NULL,
    [promotion_name] VARCHAR (50)    DEFAULT ('50 Points First Tap') NOT NULL,
    [card_type]      VARCHAR (50)    DEFAULT ('all') NOT NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

