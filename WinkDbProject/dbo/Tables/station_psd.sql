CREATE TABLE [dbo].[station_psd] (
    [Station]  NVARCHAR (255) NULL,
    [panel]    FLOAT (53)     NULL,
    [asm_name] NVARCHAR (255) NULL,
    [network]  NVARCHAR (255) NULL,
    [asm_code] VARCHAR (10)   DEFAULT ((0)) NOT NULL
);

