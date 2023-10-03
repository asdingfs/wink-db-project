CREATE TABLE [dbo].[wink_account_filtering_status_role] (
    [id]           INT      IDENTITY (1, 1) NOT NULL,
    [filtering_id] INT      NULL,
    [role_id]      INT      NULL,
    [created_at]   DATETIME NULL,
    [updated_at]   DATETIME NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

