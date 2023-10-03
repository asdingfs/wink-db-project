CREATE TABLE [dbo].[wink_canid_bus] (
    [id]             INT          IDENTITY (1, 1) NOT NULL,
    [csc_app_no]     VARCHAR (50) NOT NULL,
    [business_date]  DATETIME     NOT NULL,
    [total_bus_tabs] INT          DEFAULT ((0)) NOT NULL,
    [created_at]     DATETIME     NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

