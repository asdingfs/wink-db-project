CREATE TABLE [dbo].[Authen_NETS_Contactless_Cashcard] (
    [id]          INT          IDENTITY (1, 1) NOT NULL,
    [customer_id] INT          NULL,
    [nets_card]   VARCHAR (50) NULL,
    [created_at]  DATETIME     NULL,
    [updated_at]  DATETIME     NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

