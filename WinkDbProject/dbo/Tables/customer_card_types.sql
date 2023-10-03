CREATE TABLE [dbo].[customer_card_types] (
    [id]         INT          IDENTITY (1, 1) NOT NULL,
    [customerId] INT          NOT NULL,
    [cardType]   VARCHAR (20) NOT NULL,
    [createdAt]  DATETIME     NOT NULL,
    [updatedAt]  DATETIME     NOT NULL,
    CONSTRAINT [PK_customer_card_types] PRIMARY KEY CLUSTERED ([id] ASC)
);

