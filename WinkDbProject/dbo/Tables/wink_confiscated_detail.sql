CREATE TABLE [dbo].[wink_confiscated_detail] (
    [id]                 INT          IDENTITY (1, 1) NOT NULL,
    [customer_id]        INT          NULL,
    [merchant_id]        INT          NULL,
    [created_at]         DATETIME     NULL,
    [updated_at]         DATETIME     NULL,
    [total_winks]        INT          NULL,
    [year_end]           VARCHAR (10) DEFAULT ((0)) NOT NULL,
    [confiscated_from]   VARCHAR (50) NULL,
    [nets_redemption_id] INT          NULL,
    [evoucher_id]        INT          NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

