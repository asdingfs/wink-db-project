CREATE TABLE [dbo].[Booked_AllAsset_Log] (
    [id]          INT          IDENTITY (1, 1) NOT NULL,
    [campaign_id] INT          NULL,
    [booked_from] VARCHAR (20) NULL,
    [booked_to]   VARCHAR (20) NULL,
    [created_at]  DATETIME     NULL,
    [updated_at]  DATETIME     NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

