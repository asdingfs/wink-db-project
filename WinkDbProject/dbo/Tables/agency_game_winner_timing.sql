CREATE TABLE [dbo].[agency_game_winner_timing] (
    [id]            INT           IDENTITY (1, 1) NOT NULL,
    [selected_date] DATETIME      NULL,
    [time_from]     DATETIME      NULL,
    [time_to]       DATETIME      NULL,
    [created_at]    DATETIME      NULL,
    [updated_at]    DATETIME      NULL,
    [date_status]   INT           DEFAULT ((0)) NOT NULL,
    [qr_code]       VARCHAR (100) NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

