CREATE TABLE [dbo].[NETs_Sent_CANID_List] (
    [id]           INT          IDENTITY (1, 1) NOT NULL,
    [nets_can_id]  VARCHAR (20) NULL,
    [created_date] DATETIME     NULL,
    [sent_status]  INT          DEFAULT ((0)) NOT NULL,
    [updated_at]   DATETIME     NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

