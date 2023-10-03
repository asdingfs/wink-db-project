CREATE TABLE [dbo].[training_mfa_session] (
    [id]           INT           IDENTITY (1, 1) NOT NULL,
    [email]        VARCHAR (100) NOT NULL,
    [session_code] INT           NOT NULL,
    [campaign_id]  INT           NULL,
    [created_at]   DATETIME      NOT NULL,
    [expired_at]   DATETIME      NOT NULL,
    [status]       INT           NOT NULL,
    CONSTRAINT [PK_training_mfa_session] PRIMARY KEY CLUSTERED ([id] ASC)
);

