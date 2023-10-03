CREATE TABLE [dbo].[agency_qr_code] (
    [id]         INT          IDENTITY (1, 1) NOT NULL,
    [qr_code]    VARCHAR (80) NULL,
    [agency_id]  INT          NULL,
    [created_at] DATETIME     NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

