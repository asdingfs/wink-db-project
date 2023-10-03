CREATE TABLE [dbo].[splash_Adv] (
    [id]           INT           IDENTITY (1, 1) NOT NULL,
    [image_name]   VARCHAR (250) NULL,
    [image_type]   VARCHAR (50)  NULL,
    [image_status] VARCHAR (10)  NULL,
    [created_at]   DATETIME      NULL,
    [updated_at]   DATETIME      NULL,
    [from_date]    DATETIME      NULL,
    [to_date]      DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

