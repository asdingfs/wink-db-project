CREATE TABLE [dbo].[WINK_GATES_Email] (
    [id]         INT            IDENTITY (1, 1) NOT NULL,
    [campaign]   VARCHAR (200)  NOT NULL,
    [subject]    VARCHAR (200)  NULL,
    [greeting]   VARCHAR (100)  NULL,
    [first_part] VARCHAR (1000) NULL,
    [main_body]  VARCHAR (2000) NULL,
    [footer]     VARCHAR (3000) NULL,
    [img_url]    VARCHAR (500)  NULL,
    [file_name]  VARCHAR (500)  NULL,
    [created_at] DATETIME       NULL,
    CONSTRAINT [PK_WINK_GATES_Email] PRIMARY KEY CLUSTERED ([id] ASC)
);

