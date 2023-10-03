CREATE TABLE [dbo].[points_issuance_campaign] (
    [id]            INT           IDENTITY (1, 1) NOT NULL,
    [campaign_name] VARCHAR (250) NOT NULL,
    [points]        INT           NOT NULL,
    [created_at]    DATETIME      NOT NULL,
    [updated_at]    DATETIME      NOT NULL,
    CONSTRAINT [PK_points_issuance_campaign] PRIMARY KEY CLUSTERED ([id] ASC)
);

