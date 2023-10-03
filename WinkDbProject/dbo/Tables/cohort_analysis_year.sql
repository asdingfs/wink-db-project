CREATE TABLE [dbo].[cohort_analysis_year] (
    [id]             INT           IDENTITY (1, 1) NOT NULL,
    [period]         VARCHAR (255) NULL,
    [total_customer] VARCHAR (255) NULL,
    [m_d_0]          VARCHAR (255) NULL,
    [m_d_1]          VARCHAR (255) NULL,
    [m_d_2]          VARCHAR (255) NULL,
    [m_d_3]          VARCHAR (255) NULL,
    [m_d_4]          VARCHAR (255) NULL,
    [m_d_5]          VARCHAR (255) NULL,
    [m_d_6]          VARCHAR (255) NULL,
    [m_d_7]          VARCHAR (255) NULL,
    [m_d_8]          VARCHAR (255) NULL,
    [m_d_9]          VARCHAR (255) NULL,
    [m_d_10]         VARCHAR (255) NULL,
    [m_d_11]         VARCHAR (255) NULL,
    [m_d_12]         VARCHAR (255) NULL,
    [year]           VARCHAR (255) NULL,
    [created_at]     DATETIME      DEFAULT (dateadd(hour,(8),getdate())) NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

