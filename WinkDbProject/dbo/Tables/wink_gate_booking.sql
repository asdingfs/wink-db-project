CREATE TABLE [dbo].[wink_gate_booking] (
    [id]                    INT           IDENTITY (1, 1) NOT NULL,
    [wink_gate_campaign_id] INT           NOT NULL,
    [wink_gate_asset_id]    INT           NOT NULL,
    [points]                INT           NOT NULL,
    [interval]              INT           NOT NULL,
    [pushHeader]            VARCHAR (250) NULL,
    [pushMsg]               VARCHAR (500) NOT NULL,
    [linkTo]                INT           NOT NULL,
    [status]                INT           CONSTRAINT [DF_wink_gate_booking_status] DEFAULT ((1)) NULL,
    [updated_at]            DATETIME      NOT NULL,
    [created_at]            DATETIME      NOT NULL,
    CONSTRAINT [PK_wink_gate_booking] PRIMARY KEY CLUSTERED ([id] ASC)
);

