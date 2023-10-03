CREATE TABLE [dbo].[industry] (
    [industry_id]    INT           IDENTITY (1, 1) NOT NULL,
    [industry_name]  VARCHAR (100) NOT NULL,
    [created_at]     DATETIME      NULL,
    [updated_at]     DATETIME      NULL,
    [industry_image] VARCHAR (255) NULL,
    [status]         BIT           DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([industry_id] ASC)
);

