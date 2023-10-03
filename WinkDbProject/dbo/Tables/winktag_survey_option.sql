CREATE TABLE [dbo].[winktag_survey_option] (
    [option_id]     INT           IDENTITY (1, 1) NOT NULL,
    [campaign_id]   INT           NOT NULL,
    [question_id]   INT           NOT NULL,
    [option_answer] VARCHAR (250) NOT NULL,
    [status]        VARCHAR (10)  CONSTRAINT [DF__winktag_s__statu__409A7F30] DEFAULT ((1)) NOT NULL,
    [created_at]    DATETIME      NULL,
    [updated_at]    DATETIME      NULL,
    [option_type]   VARCHAR (255) NULL,
    [image_name]    VARCHAR (255) NULL,
    [answer_id]     VARCHAR (10)  NULL
);

