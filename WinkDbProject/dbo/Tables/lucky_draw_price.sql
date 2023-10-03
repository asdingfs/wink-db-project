CREATE TABLE [dbo].[lucky_draw_price] (
    [id]           INT           IDENTITY (1, 1) NOT NULL,
    [qr_code]      VARCHAR (100) NULL,
    [created_at]   DATETIME      NULL,
    [updated_at]   DATETIME      NULL,
    [prize]        VARCHAR (250) NULL,
    [event_name]   VARCHAR (250) NULL,
    [start_date]   VARCHAR (100) NULL,
    [end_date]     VARCHAR (100) NULL,
    [qty]          INT           DEFAULT ((0)) NOT NULL,
    [event_status] INT           DEFAULT ((0)) NOT NULL
);

