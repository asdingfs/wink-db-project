CREATE TABLE [dbo].[winktag_starwar_2017] (
    [id]           INT           IDENTITY (1, 1) NOT NULL,
    [customer_id]  INT           NULL,
    [starwar_code] VARCHAR (20)  NULL,
    [created_at]   DATETIME      NULL,
    [gps]          VARCHAR (150) NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

