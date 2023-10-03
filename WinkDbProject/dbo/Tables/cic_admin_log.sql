CREATE TABLE [dbo].[cic_admin_log] (
    [id]           INT           IDENTITY (1, 1) NOT NULL,
    [user_id]      INT           NOT NULL,
    [user_name]    VARCHAR (100) NOT NULL,
    [login_time]   DATETIME      NULL,
    [logout_time]  DATETIME      NULL,
    [status]       BIT           DEFAULT ((0)) NOT NULL,
    [action_count] INT           DEFAULT ((0)) NULL,
    [email]        VARCHAR (100) NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

