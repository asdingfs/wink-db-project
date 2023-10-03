CREATE TABLE [dbo].[customer_churned_for_trip] (
    [id]          INT          IDENTITY (1, 1) NOT NULL,
    [customer_id] INT          NOT NULL,
    [period]      VARCHAR (10) NOT NULL,
    [create_at]   DATETIME     NOT NULL
);

