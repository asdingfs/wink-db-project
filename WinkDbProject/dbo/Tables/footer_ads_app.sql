﻿CREATE TABLE [dbo].[footer_ads_app] (
    [id]                     INT           IDENTITY (1, 1) NOT NULL,
    [iphone6plus_image]      VARCHAR (250) NULL,
    [iphone6_image]          VARCHAR (250) NULL,
    [iphone5_image]          VARCHAR (250) NULL,
    [iphone4_image]          VARCHAR (250) NULL,
    [android_small_image]    VARCHAR (250) NULL,
    [android_large_image]    VARCHAR (250) NULL,
    [url]                    VARCHAR (250) NULL,
    [image_status]           VARCHAR (10)  NULL,
    [created_at]             DATETIME      NULL,
    [updated_at]             DATETIME      NULL,
    [from_date]              DATETIME      NULL,
    [to_date]                DATETIME      NULL,
    [name]                   VARCHAR (200) NULL,
    [redirect_status]        VARCHAR (10)  CONSTRAINT [DF__footer_ad__redir__261B931E] DEFAULT ((0)) NULL,
    [winktag_status]         INT           CONSTRAINT [DF__footer_ad__winkt__7E62A77F] DEFAULT ((1)) NOT NULL,
    [winktreats_status]      INT           CONSTRAINT [DF_footer_ads_app_winktreats_status] DEFAULT ((1)) NULL,
    [home_status]            INT           CONSTRAINT [DF__footer_ad__home___7F56CBB8] DEFAULT ((1)) NOT NULL,
    [redirect_to_winktag]    INT           CONSTRAINT [DF__footer_ad__redir__0E990F48] DEFAULT ((0)) NOT NULL,
    [redirect_to_winktreats] INT           CONSTRAINT [DF_footer_ads_app_redirect_to_winktreats] DEFAULT ((0)) NULL,
    [iphoneX_image]          VARCHAR (100) NULL,
    CONSTRAINT [PK__footer_a__3213E83FE1076DA0] PRIMARY KEY CLUSTERED ([id] ASC)
);
