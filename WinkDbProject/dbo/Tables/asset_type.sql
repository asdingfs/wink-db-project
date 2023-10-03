CREATE TABLE [dbo].[asset_type] (
    [asset_type_id]   INT           IDENTITY (1, 1) NOT NULL,
    [asset_type_name] VARCHAR (100) NOT NULL,
    [asset_type_code] VARCHAR (100) NOT NULL,
    [created_at]      DATETIME      NULL,
    [updated_at]      DATETIME      NULL,
    [jhjhjjh]         NCHAR (10)    NULL,
    PRIMARY KEY CLUSTERED ([asset_type_id] ASC)
);

