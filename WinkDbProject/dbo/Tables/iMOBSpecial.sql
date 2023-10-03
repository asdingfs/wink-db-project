CREATE TABLE [dbo].[iMOBSpecial] (
    [id]          INT           IDENTITY (1, 1) NOT NULL,
    [customer_id] INT           NULL,
    [eVoucher_id] INT           NULL,
    [event_name]  VARCHAR (100) NULL,
    [created_at]  DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

