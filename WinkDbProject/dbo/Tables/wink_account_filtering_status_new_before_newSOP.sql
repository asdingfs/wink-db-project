CREATE TABLE [dbo].[wink_account_filtering_status_new_before_newSOP] (
    [id]                             INT           IDENTITY (1, 1) NOT NULL,
    [filtering_status_name]          VARCHAR (100) NULL,
    [filtering_status_key]           VARCHAR (50)  NULL,
    [created_at]                     DATETIME      NULL,
    [updated_at]                     DATETIME      NULL,
    [internal_procedure]             VARCHAR (200) NULL,
    [filtering_status]               INT           NOT NULL,
    [filter_procedure_key]           VARCHAR (50)  NULL,
    [filter_procedure_name]          VARCHAR (100) NULL,
    [procedure_for_index_status]     INT           NOT NULL,
    [filtering_status_shortcut_name] VARCHAR (100) NULL
);

