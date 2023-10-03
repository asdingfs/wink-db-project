CREATE TABLE [dbo].[gate_booking_delink_data_log] (
    [id]                    INT            IDENTITY (1, 1) NOT NULL,
    [action_id]             INT            NOT NULL,
    [wink_gate_campaign_id] INT            NOT NULL,
    [campaign_name]         VARCHAR (500)  NOT NULL,
    [gate_id]               VARCHAR (1000) NOT NULL,
    [points]                INT            NOT NULL,
    [interval]              INT            NOT NULL,
    [push_header]           VARCHAR (250)  NOT NULL,
    [push_msg]              VARCHAR (500)  NOT NULL,
    [link_to]               INT            NOT NULL,
    [pin_desc]              VARCHAR (250)  NOT NULL,
    [pin_img]               VARCHAR (1000) NOT NULL,
    [banner_img]            VARCHAR (1000) NOT NULL,
    [banner_hyperlink]      VARCHAR (1000) NOT NULL,
    CONSTRAINT [PK_gate_booking_delink_data_log] PRIMARY KEY CLUSTERED ([id] ASC)
);

