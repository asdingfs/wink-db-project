CREATE TABLE [dbo].[merchant_role] (
    [id]               INT          IDENTITY (1, 1) NOT NULL,
    [merchant_role_id] INT          NOT NULL,
    [role_name]        VARCHAR (50) NOT NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

