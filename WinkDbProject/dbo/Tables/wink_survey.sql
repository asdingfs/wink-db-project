CREATE TABLE [dbo].[wink_survey] (
    [id]          INT          IDENTITY (1, 1) NOT NULL,
    [customer_id] INT          NULL,
    [survey_name] VARCHAR (50) NULL,
    [servey_code] VARCHAR (20) NULL,
    [create_at]   DATETIME     NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

