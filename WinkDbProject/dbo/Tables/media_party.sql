CREATE TABLE [dbo].[media_party] (
    [id]              INT           IDENTITY (1, 1) NOT NULL,
    [email]           VARCHAR (150) NULL,
    [name]            VARCHAR (150) NULL,
    [company_name]    VARCHAR (150) NULL,
    [user_status]     VARCHAR (10)  DEFAULT ((1)) NOT NULL,
    [party_year]      VARCHAR (20)  NULL,
    [check_in_status] INT           DEFAULT ((0)) NOT NULL,
    [designation]     VARCHAR (50)  NULL,
    [in_charge]       VARCHAR (50)  NULL,
    [group_name]      VARCHAR (50)  NULL,
    [register_type]   VARCHAR (10)  DEFAULT ('walkin') NOT NULL,
    [created_at]      DATETIME      DEFAULT (getdate()) NOT NULL,
    [rsvp_status]     VARCHAR (10)  DEFAULT ('No') NOT NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

