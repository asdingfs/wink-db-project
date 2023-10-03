﻿CREATE TABLE [dbo].[popup_ads_app] (
    [id]                     INT           IDENTITY (1, 1) NOT NULL,
    [iphone6plus_image]      VARCHAR (250) NULL,
    [iphone6_image]          VARCHAR (250) NULL,
    [iphone5_image]          VARCHAR (250) NULL,
    [android_image]          VARCHAR (250) NULL,
    [url]                    VARCHAR (250) NULL,
    [image_status]           VARCHAR (10)  NULL,
    [created_at]             DATETIME      NULL,
    [updated_at]             DATETIME      NULL,
    [from_date]              DATETIME      NULL,
    [to_date]                DATETIME      NULL,
    [name]                   VARCHAR (200) NULL,
    [redirect_status]        VARCHAR (10)  CONSTRAINT [DF__popup_ads__redir__25276EE5] DEFAULT ((0)) NOT NULL,
    [winktag_status]         INT           CONSTRAINT [DF__popup_ads__winkt__7A92169B] DEFAULT ((1)) NOT NULL,
    [winktreats_status]      INT           CONSTRAINT [DF_popup_ads_app_winktreats_status] DEFAULT ((1)) NULL,
    [home_status]            INT           CONSTRAINT [DF__popup_ads__home___7B863AD4] DEFAULT ((1)) NOT NULL,
    [redirect_to_winktag]    INT           CONSTRAINT [DF__popup_ads__redir__0DA4EB0F] DEFAULT ((0)) NOT NULL,
    [redirect_to_winktreats] INT           CONSTRAINT [DF_popup_ads_app_redirect_to_winktreats] DEFAULT ((0)) NULL,
    [iphoneX_image]          VARCHAR (250) NULL,
    [iphone8_image]          VARCHAR (250) NULL,
    [iphone11_image]         VARCHAR (250) NULL,
    [iphone14_image]         VARCHAR (250) NULL,
    [iphone8plus_image]      VARCHAR (250) NULL,
    CONSTRAINT [PK__popup_ad__3213E83FBCF938FD] PRIMARY KEY CLUSTERED ([id] ASC)
);

