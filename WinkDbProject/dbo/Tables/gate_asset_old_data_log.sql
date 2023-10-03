CREATE TABLE [dbo].[gate_asset_old_data_log] (
    [id]              INT            IDENTITY (1, 1) NOT NULL,
    [action_id]       INT            NOT NULL,
    [wink_gate_id]    INT            NOT NULL,
    [old_gate_id]     VARCHAR (100)  NOT NULL,
    [old_desc]        VARCHAR (250)  NOT NULL,
    [old_lat]         VARCHAR (50)   NOT NULL,
    [old_lng]         VARCHAR (50)   NOT NULL,
    [old_range]       INT            NOT NULL,
    [old_points]      INT            NULL,
    [old_interval]    INT            NULL,
    [old_push_header] VARCHAR (250)  NULL,
    [old_push_msg]    VARCHAR (500)  NULL,
    [old_link_to]     INT            NULL,
    [old_status]      INT            NULL,
    [old_pin_img]     VARCHAR (1000) NULL,
    [old_banner_img]  VARCHAR (1000) NULL,
    [old_banner_url]  VARCHAR (1000) NULL,
    CONSTRAINT [PK_gate_asset_old_data_log] PRIMARY KEY CLUSTERED ([id] ASC)
);

