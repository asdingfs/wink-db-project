CREATE TABLE [dbo].[campaign_winktag] (
    [id]             INT           IDENTITY (1, 1) NOT NULL,
    [campaign_id]    INT           NULL,
    [video_name]     VARCHAR (250) NULL,
    [created_at]     DATETIME      NULL,
    [updated_at]     DATETIME      NULL,
    [winktag_status] VARCHAR (10)  DEFAULT ((1)) NOT NULL,
    [survey_url]     VARCHAR (50)  NULL,
    [winktag_type]   VARCHAR (50)  DEFAULT ('video') NULL,
    [wink_content]   VARCHAR (250) NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

