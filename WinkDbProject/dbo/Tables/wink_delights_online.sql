CREATE TABLE [dbo].[wink_delights_online] (
    [id]           INT           IDENTITY (1, 1) NOT NULL,
    [campaign_id]  INT           NOT NULL,
    [order_number] VARCHAR (250) NOT NULL,
    [cus_id]       INT           NOT NULL,
    [cus_date]     DATETIME      NOT NULL,
    [cus_ip]       VARCHAR (255) NULL,
    [cus_location] VARCHAR (255) NULL,
    [mer_id]       INT           NULL,
    [mer_date]     DATETIME      NULL,
    [mer_ip]       VARCHAR (255) NULL,
    [mer_location] VARCHAR (255) NULL,
    [completion]   INT           NULL,
    [validity]     VARCHAR (50)  NULL,
    [points]       INT           NULL,
    [exception]    VARCHAR (255) NULL,
    CONSTRAINT [PK_online_ordering] PRIMARY KEY CLUSTERED ([id] ASC)
);

