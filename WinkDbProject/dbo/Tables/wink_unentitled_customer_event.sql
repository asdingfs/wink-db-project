CREATE TABLE [dbo].[wink_unentitled_customer_event] (
    [id]            INT           IDENTITY (1, 1) NOT NULL,
    [email]         VARCHAR (250) NULL,
    [event_name]    VARCHAR (100) NULL,
    [created_at]    DATETIME      NULL,
    [customer_id]   INT           NULL,
    [disabled_date] VARCHAR (10)  NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

