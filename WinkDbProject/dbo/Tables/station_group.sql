CREATE TABLE [dbo].[station_group] (
    [station_group_id]   INT           IDENTITY (1, 1) NOT NULL,
    [station_group_name] VARCHAR (500) CONSTRAINT [DF_asset_type_group_asset_type_group_name] DEFAULT ('normal') NOT NULL,
    CONSTRAINT [PK_asset_type_group] PRIMARY KEY CLUSTERED ([station_group_id] ASC)
);

