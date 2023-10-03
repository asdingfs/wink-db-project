CREATE TABLE [dbo].[monthly_qrscan_records] (
    [id]          INT          IDENTITY (1, 1) NOT NULL,
    [scan_year]   VARCHAR (10) NULL,
    [scan_peroid] VARCHAR (20) NULL,
    [total_scans] INT          DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

