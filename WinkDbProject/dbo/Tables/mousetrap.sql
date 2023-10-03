CREATE TABLE [dbo].[mousetrap] (
    [mousetrap_id] INT           IDENTITY (1, 1) NOT NULL,
    [time_traped]  DATETIME      NULL,
    [ip_traped]    VARCHAR (100) NULL,
    [isp_name]     VARCHAR (100) NULL,
    [from_where]   VARCHAR (500) NULL,
    [status]       VARCHAR (100) NULL,
    [updated_at]   DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([mousetrap_id] ASC)
);

