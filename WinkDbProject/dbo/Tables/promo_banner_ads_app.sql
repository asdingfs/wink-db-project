CREATE TABLE [dbo].[promo_banner_ads_app] (
    [id]                  INT           IDENTITY (1, 1) NOT NULL,
    [banner_name]         VARCHAR (250) NOT NULL,
    [banner_image]        VARCHAR (250) NOT NULL,
    [banner_url]          VARCHAR (250) NULL,
    [banner_from_date]    DATETIME      NULL,
    [banner_to_date]      DATETIME      NULL,
    [banner_image_status] VARCHAR (10)  NOT NULL,
    [promo_banner_type]   VARCHAR (20)  NOT NULL,
    [created_at]          DATETIME      DEFAULT (getdate()) NULL,
    [updated_at]          DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

