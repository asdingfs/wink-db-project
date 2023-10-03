CREATE TABLE [dbo].[training_email_wid_link] (
    [id]          INT           IDENTITY (1, 1) NOT NULL,
    [email]       VARCHAR (100) NOT NULL,
    [wid]         VARCHAR (50)  NOT NULL,
    [campaign_id] INT           NULL,
    [created_at]  DATETIME      NOT NULL,
    CONSTRAINT [PK_training_email_wid_link_1] PRIMARY KEY CLUSTERED ([id] ASC)
);

