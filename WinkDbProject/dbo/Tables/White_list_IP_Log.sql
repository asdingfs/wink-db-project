CREATE TABLE [dbo].[White_list_IP_Log] (
    [id]                 INT           IDENTITY (1, 1) NOT NULL,
    [email]              VARCHAR (100) NULL,
    [home_ip]            VARCHAR (100) NULL,
    [mobile_ip]          VARCHAR (100) NULL,
    [updated]            DATETIME      NULL,
    [old_home_ip]        VARCHAR (100) NULL,
    [old_mobile_ip]      VARCHAR (100) NULL,
    [responsible_person] VARCHAR (100) NULL,
    [action_type]        VARCHAR (100) NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

