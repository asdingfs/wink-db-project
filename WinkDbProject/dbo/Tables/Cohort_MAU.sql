CREATE TABLE [dbo].[Cohort_MAU] (
    [id]          INT          IDENTITY (1, 1) NOT NULL,
    [period]      VARCHAR (50) NULL,
    [churned]     INT          NULL,
    [resurrected] INT          NULL,
    [newuser]     INT          NULL,
    [quickratio]  INT          NULL,
    [retention]   INT          NULL,
    [year]        INT          NULL
);

