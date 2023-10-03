CREATE TABLE [dbo].[station] (
    [station_id]   INT           IDENTITY (1, 1) NOT NULL,
    [station_code] VARCHAR (255) NOT NULL,
    [station_name] VARCHAR (255) NOT NULL,
    [created_at]   DATETIME      NULL,
    [updated_at]   DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([station_id] ASC)
);

