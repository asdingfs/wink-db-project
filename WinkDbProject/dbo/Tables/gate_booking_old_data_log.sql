CREATE TABLE [dbo].[gate_booking_old_data_log] (
    [id]                    INT            IDENTITY (1, 1) NOT NULL,
    [action_id]             INT            NOT NULL,
    [wink_gate_campaign_id] INT            NOT NULL,
    [campaign_name]         VARCHAR (500)  NULL,
    [old_gate_id]           VARCHAR (1000) NOT NULL,
    [old_points]            INT            NOT NULL,
    [old_interval]          INT            NOT NULL,
    [old_push_header]       VARCHAR (250)  NULL,
    [old_push_msg]          VARCHAR (500)  NULL,
    [old_link_to]           INT            NULL,
    [old_pin_desc]          VARCHAR (250)  NULL,
    [old_pin_img]           VARCHAR (1000) NOT NULL,
    [old_banner_img]        VARCHAR (1000) NULL,
    [old_banner_hyperlink]  VARCHAR (1000) NULL,
    CONSTRAINT [PK_gate_campaign_old_data_log] PRIMARY KEY CLUSTERED ([id] ASC)
);

