CREATE TABLE [dbo].[winktag_approved_phone_list] (
    [id]          INT           IDENTITY (1, 1) NOT NULL,
    [campaign_id] INT           NULL,
    [phone_no]    VARCHAR (100) NULL,
    [created_at]  DATETIME      NULL
);

