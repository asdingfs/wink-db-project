CREATE TABLE [dbo].[campaign_small_image] (
    [id]                 INT           IDENTITY (1, 1) NOT NULL,
    [campaign_id]        INT           NULL,
    [small_image_name]   VARCHAR (250) NULL,
    [small_image_url]    VARCHAR (250) NULL,
    [small_image_status] VARCHAR (10)  NULL,
    [created_at]         DATETIME      NULL,
    [updated_at]         DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

