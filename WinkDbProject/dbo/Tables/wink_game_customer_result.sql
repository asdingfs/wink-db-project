CREATE TABLE [dbo].[wink_game_customer_result] (
    [id]                  INT           IDENTITY (1, 1) NOT NULL,
    [session_id]          INT           NOT NULL,
    [customer_id]         INT           NOT NULL,
    [campaign_id]         INT           NOT NULL,
    [option_id]           INT           NOT NULL,
    [ip_address]          VARCHAR (100) NULL,
    [gps_location]        VARCHAR (200) NULL,
    [point]               INT           NULL,
    [winner]              VARCHAR (5)   NULL,
    [created_at]          DATETIME      NOT NULL,
    [redemption_code]     VARCHAR (30)  NULL,
    [redemption_status]   VARCHAR (5)   NULL,
    [redeemed_on]         DATETIME      NULL,
    [redemption_location] VARCHAR (200) NULL,
    CONSTRAINT [PK_wink_game_user_result] PRIMARY KEY CLUSTERED ([id] ASC)
);

