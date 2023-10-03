CREATE TABLE [dbo].[winktag_survey_question] (
    [question_id] INT            IDENTITY (1, 1) NOT NULL,
    [campaign_id] INT            NOT NULL,
    [question]    VARCHAR (8000) NOT NULL,
    [points]      INT            DEFAULT ((0)) NULL,
    [status]      VARCHAR (10)   DEFAULT ((1)) NOT NULL,
    [created_at]  DATETIME       NULL,
    [updated_at]  DATETIME       NULL,
    [question_no] VARCHAR (10)   NULL
);

