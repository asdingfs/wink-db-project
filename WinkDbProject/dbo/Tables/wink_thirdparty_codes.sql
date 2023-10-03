CREATE TABLE [dbo].[wink_thirdparty_codes] (
    [id]         INT         IDENTITY (1, 1) NOT NULL,
    [campaignId] INT         NOT NULL,
    [code]       VARCHAR (8) NOT NULL,
    [usedStatus] INT         NULL,
    [updatedAt]  DATETIME    NULL,
    [createdAt]  DATETIME    NULL,
    CONSTRAINT [PK_wink_thirdparty_codes] PRIMARY KEY CLUSTERED ([id] ASC)
);

