CREATE TABLE [dbo].[game_checkpoint_mapping_new] (
    [id]                   INT            IDENTITY (1, 1) NOT NULL,
    [from_checkpoint_qr]   VARCHAR (250)  NULL,
    [to_checkpoint_qr]     VARCHAR (1000) NULL,
    [event_date]           DATETIME       NULL,
    [created_at]           DATETIME       NULL,
    [updated_at]           DATETIME       NULL,
    [check_point_no]       INT            DEFAULT ((0)) NOT NULL,
    [event_id]             INT            DEFAULT ((0)) NOT NULL,
    [to_checkpoint_image1] VARCHAR (100)  NULL,
    [to_checkpoint_image2] VARCHAR (100)  NULL,
    [to_checkpoint_image3] VARCHAR (100)  NULL,
    [to_checkpoint_name]   VARCHAR (100)  NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

