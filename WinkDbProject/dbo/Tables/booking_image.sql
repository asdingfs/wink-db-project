CREATE TABLE [dbo].[booking_image] (
    [id]                   INT           IDENTITY (1, 1) NOT NULL,
    [booking_id]           INT           NULL,
    [campaign_id]          INT           NULL,
    [booking_image_name]   VARCHAR (250) NULL,
    [booking_image_url]    VARCHAR (250) NULL,
    [booking_image_status] VARCHAR (10)  NULL,
    [created_at]           DATETIME      NULL,
    [updated_at]           DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

