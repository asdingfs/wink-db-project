CREATE TABLE [dbo].[game_checkpoint_detail_old] (
    [id]                     INT            IDENTITY (1, 1) NOT NULL,
    [checkpoint_name]        VARCHAR (250)  NULL,
    [checkpoint_description] VARCHAR (1000) NULL,
    [hint_image1]            VARCHAR (250)  NULL,
    [hint_image2]            VARCHAR (250)  NULL,
    [full_image]             VARCHAR (250)  NULL,
    [asset_management_id]    INT            NULL,
    [qr_code]                VARCHAR (100)  NULL,
    [booking_id]             INT            NULL,
    [location_id]            INT            NULL,
    [created_at]             DATETIME       NULL,
    [updated_at]             DATETIME       NULL,
    [game_hint_url]          VARCHAR (1000) NULL,
    [small_image]            VARCHAR (250)  NULL,
    [event_id]               INT            NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

