CREATE TABLE [dbo].[customer_migration_062016] (
    [customer_id]      INT           IDENTITY (1, 1) NOT NULL,
    [first_name]       VARCHAR (100) NOT NULL,
    [last_name]        VARCHAR (100) NOT NULL,
    [email]            VARCHAR (200) NOT NULL,
    [password]         VARCHAR (200) NOT NULL,
    [gender]           NCHAR (10)    NULL,
    [date_of_birth]    VARCHAR (100) NULL,
    [created_at]       DATETIME      NULL,
    [updated_at]       DATETIME      NULL,
    [imob_customer_id] INT           NOT NULL,
    [phone_no]         VARCHAR (10)  NULL,
    [action_status]    VARCHAR (10)  DEFAULT ('new') NOT NULL
);

