CREATE TABLE [dbo].[agency_package_points] (
    [id]             INT      IDENTITY (1, 1) NOT NULL,
    [package_points] INT      DEFAULT ((0)) NOT NULL,
    [agency_id]      INT      NOT NULL,
    [created_at]     DATETIME NULL,
    [updated_at]     DATETIME NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

