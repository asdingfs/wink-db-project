CREATE TABLE [dbo].[viral_leaders] (
    [id]          INT IDENTITY (1, 1) NOT NULL,
    [customer_id] INT NOT NULL,
    [campaign_id] INT NOT NULL,
    CONSTRAINT [PK_viral_leaders] PRIMARY KEY CLUSTERED ([id] ASC)
);

