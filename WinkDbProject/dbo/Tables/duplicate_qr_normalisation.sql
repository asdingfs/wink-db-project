CREATE TABLE [dbo].[duplicate_qr_normalisation] (
    [id]               INT           IDENTITY (1, 1) NOT NULL,
    [customerId]       INT           NULL,
    [qrCode]           VARCHAR (200) NULL,
    [duplicateCount]   INT           NULL,
    [normalisedPoints] INT           NULL,
    [affectedDate]     DATETIME      NULL,
    [createdOn]        DATETIME      NULL,
    CONSTRAINT [PK_duplicate_qr_normalisation] PRIMARY KEY CLUSTERED ([id] ASC)
);

