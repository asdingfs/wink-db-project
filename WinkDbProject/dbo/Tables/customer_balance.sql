CREATE TABLE [dbo].[customer_balance] (
    [customer_balanced_id]   INT             IDENTITY (1, 1) NOT NULL,
    [customer_id]            INT             DEFAULT ((0)) NOT NULL,
    [total_points]           DECIMAL (12, 2) NULL,
    [used_points]            INT             DEFAULT ((0)) NOT NULL,
    [total_winks]            INT             DEFAULT ((0)) NOT NULL,
    [used_winks]             INT             DEFAULT ((0)) NOT NULL,
    [total_evouchers]        INT             DEFAULT ((0)) NOT NULL,
    [total_used_evouchers]   INT             DEFAULT ((0)) NOT NULL,
    [confiscated_winks]      INT             DEFAULT ((0)) NOT NULL,
    [expired_winks]          INT             DEFAULT ((0)) NOT NULL,
    [confiscated_points]     INT             DEFAULT ((0)) NULL,
    [ip_scanned]             VARCHAR (100)   NULL,
    [confiscated_winks_year] INT             DEFAULT ((0)) NOT NULL,
    [total_scans]            INT             DEFAULT ((0)) NOT NULL,
    [total_redeemed_amt]     DECIMAL (12, 2) NULL,
    CONSTRAINT [PK__customer__E439DA05A85BC792] PRIMARY KEY CLUSTERED ([customer_balanced_id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IDX_customer_balance]
    ON [dbo].[customer_balance]([customer_id] ASC);

