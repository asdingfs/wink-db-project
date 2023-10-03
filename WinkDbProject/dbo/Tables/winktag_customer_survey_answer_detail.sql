CREATE TABLE [dbo].[winktag_customer_survey_answer_detail] (
    [id]            INT            IDENTITY (1, 1) NOT NULL,
    [customer_id]   INT            NOT NULL,
    [campaign_id]   INT            NOT NULL,
    [question_id]   INT            DEFAULT ((0)) NULL,
    [option_id]     INT            DEFAULT ((0)) NULL,
    [option_answer] VARCHAR (250)  NULL,
    [answer]        VARCHAR (1000) NULL,
    [created_at]    DATETIME       NULL,
    [question_no]   VARCHAR (10)   NULL,
    [row_count]     INT            DEFAULT ((1)) NULL,
    [GPS_location]  VARCHAR (255)  NULL,
    [ip_address]    VARCHAR (255)  NULL
);

