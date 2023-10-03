CREATE TABLE [dbo].[game_player_checkpoints_detail] (
    [id]                  INT           IDENTITY (1, 1) NOT NULL,
    [customer_id]         INT           NOT NULL,
    [campaign_booking_id] INT           NOT NULL,
    [points]              DECIMAL (18)  NOT NULL,
    [last_scanned_time]   DATETIME      NOT NULL,
    [qr_code]             VARCHAR (200) NULL,
    [created_at]          DATETIME      NULL,
    [campaign_id]         INT           NULL,
    [check_point_no]      INT           NULL,
    [event_id]            INT           NULL,
    [event_date]          DATETIME      NULL,
    [team_id]             INT           NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

