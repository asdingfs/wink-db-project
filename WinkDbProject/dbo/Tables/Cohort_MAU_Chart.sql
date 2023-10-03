CREATE TABLE [dbo].[Cohort_MAU_Chart] (
    [id]                          INT             IDENTITY (1, 1) NOT NULL,
    [year]                        INT             NOT NULL,
    [period]                      VARCHAR (20)    NOT NULL,
    [registered_customer_todate]  INT             CONSTRAINT [DF__Cohort_MA__new_c__0ECE1972] DEFAULT ((0)) NOT NULL,
    [new_customer]                INT             NULL,
    [active_user]                 INT             NULL,
    [churned]                     INT             CONSTRAINT [DF__Cohort_MA__churn__0FC23DAB] DEFAULT ((0)) NOT NULL,
    [resurrected]                 INT             CONSTRAINT [DF__Cohort_MA__resur__10B661E4] DEFAULT ((0)) NOT NULL,
    [locked_todate_prev_month]    INT             NULL,
    [locked_todate_current_month] INT             NULL,
    [retention]                   DECIMAL (10, 2) CONSTRAINT [DF__Cohort_MA__reten__11AA861D] DEFAULT ((0.00)) NOT NULL,
    [quick_ratio]                 DECIMAL (10, 2) CONSTRAINT [DF__Cohort_MA__quick__129EAA56] DEFAULT ((0.00)) NOT NULL,
    [created_at]                  DATETIME        NULL,
    [updated_at]                  DATETIME        NULL
);

