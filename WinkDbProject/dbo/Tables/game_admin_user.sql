CREATE TABLE [dbo].[game_admin_user] (
    [admin_user_id] INT            IDENTITY (1, 1) NOT NULL,
    [email]         VARCHAR (100)  NOT NULL,
    [password]      NVARCHAR (100) NOT NULL,
    [admin_role_id] INT            NOT NULL
);

