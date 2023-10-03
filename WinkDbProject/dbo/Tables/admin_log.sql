CREATE TABLE [dbo].[admin_log] (
    [id]           INT           IDENTITY (1, 1) NOT NULL,
    [user_id]      INT           NOT NULL,
    [user_name]    VARCHAR (100) NOT NULL,
    [login_time]   DATETIME      NULL,
    [logout_time]  DATETIME      NULL,
    [status]       BIT           CONSTRAINT [DF__admin_log__statu__3E1D39E1] DEFAULT ((0)) NOT NULL,
    [action_count] INT           CONSTRAINT [DF__admin_log__actio__39AD8A7F] DEFAULT ((0)) NOT NULL,
    CONSTRAINT [PK__admin_lo__3213E83FAF353858] PRIMARY KEY CLUSTERED ([id] ASC)
);

