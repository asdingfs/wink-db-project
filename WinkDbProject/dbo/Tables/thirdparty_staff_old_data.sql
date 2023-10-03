CREATE TABLE [dbo].[thirdparty_staff_old_data] (
    [id]                INT            IDENTITY (1, 1) NOT NULL,
    [action_id]         INT            NULL,
    [staff_id]          INT            NULL,
    [email]             VARCHAR (100)  NULL,
    [password]          NVARCHAR (100) NULL,
    [first_name]        NVARCHAR (100) NULL,
    [last_name]         NVARCHAR (100) NULL,
    [staff_role_id]     INT            NOT NULL,
    [parent_role_id]    INT            NOT NULL,
    [parent_name]       VARCHAR (150)  NULL,
    [auth_token]        VARCHAR (150)  NOT NULL,
    [created_at]        DATETIME       NULL,
    [status]            VARCHAR (10)   DEFAULT ('enable') NOT NULL,
    [action_created_at] DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

