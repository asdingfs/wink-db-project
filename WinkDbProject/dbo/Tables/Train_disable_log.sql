CREATE TABLE [dbo].[Train_disable_log] (
    [id]            INT           IDENTITY (1, 1) NOT NULL,
    [customer_id]   INT           NULL,
    [action_status] VARCHAR (50)  NULL,
    [created_at]    DATETIME      NULL,
    [reason]        VARCHAR (200) NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

