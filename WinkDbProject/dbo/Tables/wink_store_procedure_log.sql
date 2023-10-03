CREATE TABLE [dbo].[wink_store_procedure_log] (
    [id]           INT            IDENTITY (1, 1) NOT NULL,
    [sp_name]      VARCHAR (256)  NULL,
    [msg_type]     VARCHAR (20)   NULL,
    [msg_content]  VARCHAR (2048) NULL,
    [created_time] DATETIME       NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

