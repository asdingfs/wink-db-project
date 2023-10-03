CREATE TABLE [dbo].[GSS_event] (
    [id]            INT           IDENTITY (1, 1) NOT NULL,
    [qr_code_value] VARCHAR (100) NULL,
    [created_at]    DATETIME      NULL,
    [email]         VARCHAR (200) NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

