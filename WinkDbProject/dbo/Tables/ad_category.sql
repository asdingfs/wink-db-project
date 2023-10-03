CREATE TABLE [dbo].[ad_category] (
    [ad_category_id] INT           NOT NULL,
    [panel_no]       VARCHAR (50)  NULL,
    [media_scheme]   VARCHAR (100) NULL,
    [created_at]     DATETIME      NULL,
    [updated_at]     DATETIME      NULL,
    CONSTRAINT [PK_ad_category] PRIMARY KEY CLUSTERED ([ad_category_id] ASC)
);

