CREATE TABLE [dbo].[TBL_WINKPLAY_WINKHUNT_CODES] (
    [WP_WH_CODES_ID]   INT          IDENTITY (1, 1) NOT NULL,
    [promo_code]       VARCHAR (16) NULL,
    [wink_point_value] INT          DEFAULT ((0)) NULL,
    [used_status]      INT          DEFAULT ((0)) NULL,
    [created_on]       DATETIME     NULL,
    [updated_on]       DATETIME     NULL,
    [campaign_id]      INT          NOT NULL,
    PRIMARY KEY CLUSTERED ([WP_WH_CODES_ID] ASC),
    CONSTRAINT [UC_promo_code] UNIQUE NONCLUSTERED ([promo_code] ASC)
);

