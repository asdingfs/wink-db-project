CREATE TABLE [dbo].[app_loading_page] (
    [id]                INT           IDENTITY (1, 1) NOT NULL,
    [iphone6plus_image] VARCHAR (250) NULL,
    [iphone6_image]     VARCHAR (250) NULL,
    [iphone5_image]     VARCHAR (250) NULL,
    [android_image]     VARCHAR (250) NULL,
    [url]               VARCHAR (250) NULL,
    [image_status]      VARCHAR (10)  NULL,
    [created_at]        DATETIME      NULL,
    [updated_at]        DATETIME      NULL,
    [from_date]         DATETIME      NULL,
    [to_date]           DATETIME      NULL,
    [name]              VARCHAR (200) NULL,
    [iphoneX_image]     VARCHAR (250) NULL,
    CONSTRAINT [PK__app_load__3213E83F77CB8F9D] PRIMARY KEY CLUSTERED ([id] ASC)
);

