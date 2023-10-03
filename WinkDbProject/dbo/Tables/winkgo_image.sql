CREATE TABLE [dbo].[winkgo_image] (
    [id]                     INT           IDENTITY (1, 1) NOT NULL,
    [campaign_id]            INT           NULL,
    [image_status]           INT           DEFAULT ((0)) NOT NULL,
    [from_date]              DATETIME      NULL,
    [to_date]                DATETIME      NULL,
    [created_at]             DATETIME      NULL,
    [updated_at]             DATETIME      NULL,
    [winkgo_small_image]     VARCHAR (200) NULL,
    [winkgo_small_image_url] VARCHAR (500) NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

