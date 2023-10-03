CREATE TABLE [dbo].[wink_admin_ip] (
    [id]         INT           IDENTITY (1, 1) NOT NULL,
    [ip_address] VARCHAR (100) NULL,
    [created_at] DATETIME      NULL,
    [updated_at] DATETIME      NULL,
    [admin_id]   INT           NULL,
    [ip_type]    VARCHAR (50)  NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

