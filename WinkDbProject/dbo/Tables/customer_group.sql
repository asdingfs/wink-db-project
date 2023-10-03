CREATE TABLE [dbo].[customer_group] (
    [id]         INT          IDENTITY (1, 1) NOT NULL,
    [group_id]   INT          NULL,
    [group_name] VARCHAR (50) NULL,
    [created_at] DATETIME     NULL,
    [updated_at] DATETIME     NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

