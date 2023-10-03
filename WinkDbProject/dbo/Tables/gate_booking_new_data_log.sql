CREATE TABLE [dbo].[gate_booking_new_data_log] (
    [id]                    INT            IDENTITY (1, 1) NOT NULL,
    [action_id]             INT            NOT NULL,
    [wink_gate_campaign_id] INT            NOT NULL,
    [campaign_name]         VARCHAR (500)  NULL,
    [new_gate_id]           VARCHAR (1000) NULL,
    [new_points]            INT            NOT NULL,
    [new_interval]          INT            NOT NULL,
    [new_push_header]       VARCHAR (250)  NULL,
    [new_push_msg]          VARCHAR (500)  NULL,
    [new_link_to]           INT            NOT NULL,
    [new_pin_desc]          VARCHAR (250)  NULL,
    [new_pin_img]           VARCHAR (1000) NOT NULL,
    [new_banner_img]        VARCHAR (1000) NULL,
    [new_banner_hyperlink]  VARCHAR (1000) NULL,
    CONSTRAINT [PK_gate_campaign_new_data_log] PRIMARY KEY CLUSTERED ([id] ASC)
);

