CREATE TABLE [dbo].[media_party111] (
    [id]              INT           NOT NULL,
    [email]           VARCHAR (150) NULL,
    [name]            VARCHAR (150) NULL,
    [company_name]    VARCHAR (150) NULL,
    [user_status]     VARCHAR (10)  NOT NULL,
    [party_year]      VARCHAR (20)  NULL,
    [check_in_status] INT           NOT NULL,
    [designation]     VARCHAR (50)  NULL,
    [in_charge]       VARCHAR (50)  NULL,
    [group_name]      VARCHAR (50)  NULL,
    [register_type]   VARCHAR (10)  NOT NULL,
    [created_at]      DATETIME      NOT NULL,
    [rsvp_status]     VARCHAR (10)  NOT NULL
);

