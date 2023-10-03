CREATE TABLE [dbo].[gate_asset_new_data_log] (
    [id]              INT            IDENTITY (1, 1) NOT NULL,
    [action_id]       INT            NOT NULL,
    [wink_gate_id]    INT            NOT NULL,
    [new_gate_id]     VARCHAR (100)  NOT NULL,
    [new_desc]        VARCHAR (250)  NOT NULL,
    [new_lat]         VARCHAR (50)   NOT NULL,
    [new_lng]         VARCHAR (50)   NOT NULL,
    [new_range]       INT            NOT NULL,
    [new_points]      INT            NULL,
    [new_interval]    INT            NULL,
    [new_push_header] VARCHAR (250)  NULL,
    [new_push_msg]    VARCHAR (500)  NULL,
    [new_link_to]     INT            NULL,
    [new_status]      INT            NULL,
    [new_pin_img]     VARCHAR (1000) NULL,
    [new_banner_img]  VARCHAR (1000) NULL,
    [new_banner_url]  VARCHAR (1000) NULL,
    CONSTRAINT [PK_gate_asset_new_data_log] PRIMARY KEY CLUSTERED ([id] ASC)
);

