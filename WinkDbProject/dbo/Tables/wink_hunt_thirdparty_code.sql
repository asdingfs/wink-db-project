CREATE TABLE [dbo].[wink_hunt_thirdparty_code] (
    [id]          INT             IDENTITY (1, 1) NOT NULL,
    [campaign_id] INT             NULL,
    [value]       DECIMAL (10, 2) DEFAULT ((0)) NULL,
    [game_code]   VARCHAR (110)   NULL,
    [used_status] INT             DEFAULT ((0)) NOT NULL,
    [created_at]  DATETIME        NULL,
    [updated_at]  DATETIME        NULL
);

