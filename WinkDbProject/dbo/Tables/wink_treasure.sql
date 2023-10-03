CREATE TABLE [dbo].[wink_treasure] (
    [id]             INT           IDENTITY (1, 1) NOT NULL,
    [qr_code]        VARCHAR (100) NULL,
    [created_at]     DATETIME      NULL,
    [from_date]      DATETIME      NULL,
    [to_date]        DATETIME      NULL,
    [prize]          VARCHAR (150) NULL,
    [total_quantity] INT           DEFAULT ((0)) NOT NULL,
    [scan_value]     INT           DEFAULT ((1)) NOT NULL,
    [scan_interval]  INT           DEFAULT ((24)) NOT NULL,
    [event_name]     VARCHAR (25)  NULL,
    [redeemed_qty]   INT           DEFAULT ((0)) NOT NULL,
    [prize_type]     VARCHAR (20)  DEFAULT ('points') NOT NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

