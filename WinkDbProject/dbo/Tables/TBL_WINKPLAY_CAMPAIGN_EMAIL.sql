CREATE TABLE [dbo].[TBL_WINKPLAY_CAMPAIGN_EMAIL] (
    [WP_CAMP_EMAIL_ID] INT            IDENTITY (1, 1) NOT NULL,
    [first_line]       VARCHAR (300)  NULL,
    [title]            VARCHAR (200)  NULL,
    [email_message]    VARCHAR (3000) NULL,
    [created_on]       DATETIME       NULL,
    [updated_on]       DATETIME       NULL,
    [campaign_id]      INT            NOT NULL,
    PRIMARY KEY CLUSTERED ([WP_CAMP_EMAIL_ID] ASC)
);

