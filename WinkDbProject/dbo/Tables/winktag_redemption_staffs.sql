CREATE TABLE [dbo].[winktag_redemption_staffs] (
    [staff_id]     INT           IDENTITY (1, 1) NOT NULL,
    [staff_name]   VARCHAR (100) NULL,
    [staff_code]   VARCHAR (10)  NULL,
    [staff_status] VARCHAR (10)  NOT NULL,
    [campaign_id]  INT           NOT NULL,
    [created_at]   DATETIME      NULL,
    CONSTRAINT [PK_winktak_redemption_staffs] PRIMARY KEY CLUSTERED ([staff_id] ASC)
);

