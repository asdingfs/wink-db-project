CREATE TABLE [dbo].[wink_game_customer_log] (
    [id]                     INT           IDENTITY (1, 1) NOT NULL,
    [session_id]             INT           NOT NULL,
    [customer_id]            INT           NOT NULL,
    [campaign_id]            INT           NOT NULL,
    [ip_address]             VARCHAR (100) NULL,
    [gps_location]           VARCHAR (200) NULL,
    [created_at]             DATETIME      NOT NULL,
    [survey_complete_status] INT           NOT NULL,
    [character]              INT           NULL,
    CONSTRAINT [PK_wink_game_user_log] PRIMARY KEY CLUSTERED ([id] ASC)
);

