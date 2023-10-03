CREATE TABLE [dbo].[customer_balance_wink_expired_2020] (
    [customer_balanced_id]   INT             IDENTITY (1, 1) NOT NULL,
    [customer_id]            INT             NOT NULL,
    [total_points]           DECIMAL (12, 2) NULL,
    [used_points]            INT             NOT NULL,
    [total_winks]            INT             NOT NULL,
    [used_winks]             INT             NOT NULL,
    [total_evouchers]        INT             NOT NULL,
    [total_used_evouchers]   INT             NOT NULL,
    [confiscated_winks]      INT             NOT NULL,
    [expired_winks]          INT             NOT NULL,
    [confiscated_points]     INT             NULL,
    [ip_scanned]             VARCHAR (100)   NULL,
    [confiscated_winks_year] INT             NOT NULL,
    [total_scans]            INT             NOT NULL,
    [total_redeemed_amt]     DECIMAL (12, 2) NULL
);

