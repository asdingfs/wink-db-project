CREATE TABLE [dbo].[wink_gate_pin] (
    [id]                   INT            IDENTITY (1, 1) NOT NULL,
    [wink_gate_booking_id] INT            NULL,
    [description]          VARCHAR (250)  NULL,
    [image_url]            VARCHAR (1000) NOT NULL,
    [created_at]           DATETIME       NOT NULL,
    [updated_at]           DATETIME       NOT NULL,
    CONSTRAINT [PK_wink_gate_pin_image] PRIMARY KEY CLUSTERED ([id] ASC)
);

