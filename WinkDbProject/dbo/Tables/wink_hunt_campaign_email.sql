CREATE TABLE [dbo].[wink_hunt_campaign_email] (
    [id]            INT            IDENTITY (1, 1) NOT NULL,
    [campaign_id]   INT            NOT NULL,
    [first_line]    VARCHAR (300)  NULL,
    [created_at]    DATETIME       NULL,
    [title]         VARCHAR (200)  NULL,
    [email_message] VARCHAR (2000) NULL
);

