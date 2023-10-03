CREATE TABLE [dbo].[system_key_value] (
    [id]           INT             IDENTITY (1, 1) NOT NULL,
    [system_key]   VARCHAR (100)   NULL,
    [system_value] DECIMAL (10, 2) NULL,
    [name]         VARCHAR (255)   NULL,
    [rate_type]    VARCHAR (50)    NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

