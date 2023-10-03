CREATE TABLE [dbo].[thirdparty_staff] (
    [staff_id]       INT            IDENTITY (1, 1) NOT NULL,
    [email]          VARCHAR (100)  NULL,
    [password]       NVARCHAR (100) NULL,
    [first_name]     NVARCHAR (100) NULL,
    [last_name]      NVARCHAR (100) NULL,
    [staff_role_id]  INT            NOT NULL,
    [parent_role_id] INT            NOT NULL,
    [parent_name]    VARCHAR (150)  NULL,
    [auth_token]     VARCHAR (150)  NOT NULL,
    [created_at]     DATETIME       NULL,
    [status]         VARCHAR (10)   DEFAULT ('enable') NULL,
    PRIMARY KEY CLUSTERED ([staff_id] ASC)
);

