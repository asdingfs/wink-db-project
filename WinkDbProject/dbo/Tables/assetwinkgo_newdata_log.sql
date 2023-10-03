CREATE TABLE [dbo].[assetwinkgo_newdata_log] (
    [id]              INT           IDENTITY (1, 1) NOT NULL,
    [action_id]       INT           NOT NULL,
    [new_name]        VARCHAR (250) NULL,
    [new_image]       VARCHAR (250) NULL,
    [new_url]         VARCHAR (250) NULL,
    [new_campaign_id] INT           NULL,
    [new_points]      INT           NULL,
    [new_interval]    INT           NULL,
    [new_status]      VARCHAR (10)  NOT NULL,
    [new_created_at]  DATETIME      NULL,
    [new_from_date]   DATETIME      NULL,
    [new_to_date]     DATETIME      NULL,
    [new_updated_at]  DATETIME      NULL
);

