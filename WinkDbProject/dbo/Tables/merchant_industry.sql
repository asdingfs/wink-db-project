CREATE TABLE [dbo].[merchant_industry] (
    [merchant_industry_id] INT IDENTITY (1, 1) NOT NULL,
    [merchant_id]          INT NOT NULL,
    [industry_id]          INT NOT NULL,
    PRIMARY KEY CLUSTERED ([merchant_industry_id] ASC)
);

