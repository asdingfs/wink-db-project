CREATE TABLE [dbo].[admin_user] (
    [admin_user_id]     INT            IDENTITY (1, 1) NOT NULL,
    [email]             VARCHAR (100)  NULL,
    [password]          NVARCHAR (100) NULL,
    [first_name]        NVARCHAR (100) NULL,
    [last_name]         NVARCHAR (100) NULL,
    [admin_role_id]     INT            NOT NULL,
    [auth_token]        VARCHAR (150)  CONSTRAINT [DF__admin_use__auth___3B40CD36] DEFAULT ((0)) NOT NULL,
    [status]            VARCHAR (10)   CONSTRAINT [DF__admin_use__statu__6339AFF7] DEFAULT ((1)) NOT NULL,
    [home_ip]           VARCHAR (100)  NULL,
    [home_ip_updated]   DATETIME       NULL,
    [mobile_ip]         VARCHAR (100)  NULL,
    [mobile_ip_updated] DATETIME       NULL,
    [created_at]        DATETIME       NULL,
    [updated_at]        DATETIME       NULL,
    CONSTRAINT [PK_admin_user] PRIMARY KEY CLUSTERED ([admin_user_id] ASC)
);

