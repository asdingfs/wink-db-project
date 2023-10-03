CREATE TABLE [dbo].[wink_tag_approved_phone_list] (
    [id]         INT           IDENTITY (1, 1) NOT NULL,
    [phone_no]   VARCHAR (100) NULL,
    [event_name] VARCHAR (100) NULL,
    [event_id]   INT           NULL,
    [created]    DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

