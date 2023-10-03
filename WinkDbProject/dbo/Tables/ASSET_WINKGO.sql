CREATE TABLE [dbo].[ASSET_WINKGO] (
    [id]            INT           IDENTITY (1, 1) NOT NULL,
    [name]          VARCHAR (250) NULL,
    [image]         VARCHAR (250) NULL,
    [url]           VARCHAR (250) NULL,
    [campaign_id]   INT           DEFAULT ((0)) NULL,
    [points]        INT           NULL,
    [interval]      INT           DEFAULT ((0)) NULL,
    [status]        VARCHAR (10)  NOT NULL,
    [created_at]    DATETIME      NULL,
    [from_date]     DATETIME      NULL,
    [to_date]       DATETIME      NULL,
    [booked_status] VARCHAR (50)  NULL,
    [updated_at]    DATETIME      NULL
);

