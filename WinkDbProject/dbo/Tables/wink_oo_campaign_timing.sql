CREATE TABLE [dbo].[wink_oo_campaign_timing] (
    [id]             INT          IDENTITY (1, 1) NOT NULL,
    [campaign_id]    INT          NULL,
    [from_time]      DATETIME     NULL,
    [to_time]        DATETIME     NULL,
    [timing_status]  VARCHAR (10) NULL,
    [total_quantity] INT          NULL,
    [created_at]     DATETIME     NULL,
    [updated_date]   DATETIME     NULL,
    [points]         INT          DEFAULT ((0)) NOT NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

