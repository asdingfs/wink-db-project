CREATE TABLE [dbo].[winkplay_campaign_details] (
    [id]                  INT           IDENTITY (1, 1) NOT NULL,
    [campaign_id]         INT           NOT NULL,
    [age_to]              INT           DEFAULT ((0)) NULL,
    [age_from]            INT           DEFAULT ((0)) NULL,
    [gender]              VARCHAR (50)  DEFAULT ('all') NULL,
    [redirection]         VARCHAR (250) NULL,
    [banner_type]         VARCHAR (250) NOT NULL,
    [background_image]    VARCHAR (250) NULL,
    [media_file]          VARCHAR (250) NULL,
    [video_preload_image] VARCHAR (250) NULL,
    [header_text]         VARCHAR (250) NULL,
    [header_logo]         VARCHAR (250) NULL,
    [template_theme]      VARCHAR (250) NOT NULL,
    [msg_incomplete]      VARCHAR (250) DEFAULT ('You have not completed the survey.<br />Please provide an answer for every question.') NULL,
    [msg_confirmation]    VARCHAR (250) DEFAULT ('You have completed the survey.<br />Submit your answers now?') NULL,
    [msg_final]           VARCHAR (250) DEFAULT ('Thank you for participating') NULL,
    [msg_participated]    VARCHAR (250) DEFAULT ('You have already participated in this survey!') NULL,
    [created_at]          DATETIME      NULL,
    [updated_at]          DATETIME      NULL,
    UNIQUE NONCLUSTERED ([campaign_id] ASC)
);

