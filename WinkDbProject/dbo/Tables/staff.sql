CREATE TABLE [dbo].[staff] (
    [staff_id]    INT           IDENTITY (1, 1) NOT NULL,
    [merchant_id] INT           NOT NULL,
    [branch_id]   INT           NOT NULL,
    [first_name]  VARCHAR (100) NOT NULL,
    [last_name]   VARCHAR (100) NOT NULL,
    [email]       VARCHAR (255) NOT NULL,
    [password]    VARCHAR (50)  NOT NULL,
    [created_at]  DATETIME      NOT NULL,
    [updated_at]  DATETIME      NOT NULL,
    [auth_token]  VARCHAR (255) NOT NULL,
    CONSTRAINT [PK_staff] PRIMARY KEY CLUSTERED ([staff_id] ASC)
);

