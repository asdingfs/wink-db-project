CREATE TABLE [dbo].[wink_email_configure] (
    [id]             INT           IDENTITY (1, 1) NOT NULL,
    [email]          VARCHAR (150) NULL,
    [email_for]      VARCHAR (150) NULL,
    [email_password] VARCHAR (100) NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

