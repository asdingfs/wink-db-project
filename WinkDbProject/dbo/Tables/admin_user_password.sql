CREATE TABLE [dbo].[admin_user_password] (
    [id]             INT           IDENTITY (1, 1) NOT NULL,
    [admin_password] VARCHAR (150) NOT NULL,
    [admin_user_id]  INT           NULL,
    [created_at]     DATETIME      NULL,
    [updated_at]     DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

