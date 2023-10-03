CREATE TABLE [dbo].[wink_account_filtering_status] (
    [id]                    INT           IDENTITY (1, 1) NOT NULL,
    [filtering_status_name] VARCHAR (100) NULL,
    [filtering_status_key]  VARCHAR (50)  NULL,
    [created_at]            DATETIME      NULL,
    [updated_at]            DATETIME      NULL,
    [status_message]        VARCHAR (200) NULL,
    [filtering_status]      INT           DEFAULT ((1)) NOT NULL,
    [filter_procedure_key]  VARCHAR (50)  NULL,
    [filter_procedure_name] VARCHAR (100) NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

