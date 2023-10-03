CREATE TABLE [dbo].[triple_A_session_code] (
    [id]           INT         IDENTITY (1, 1) NOT NULL,
    [campaign_id]  INT         NOT NULL,
    [customer_id]  INT         NOT NULL,
    [session_code] VARCHAR (5) NOT NULL,
    [created_at]   DATETIME    NOT NULL,
    [expired_at]   DATETIME    NOT NULL,
    [status]       INT         NULL,
    CONSTRAINT [PK_3A_session_code] PRIMARY KEY CLUSTERED ([id] ASC)
);

