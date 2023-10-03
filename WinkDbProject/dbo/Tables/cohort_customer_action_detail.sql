CREATE TABLE [dbo].[cohort_customer_action_detail] (
    [id]                         INT             IDENTITY (1, 1) NOT NULL,
    [customer_action]            INT             NULL,
    [scan_action]                INT             NULL,
    [trip_action]                INT             NULL,
    [eVoucher_redemption_amount] DECIMAL (10, 2) DEFAULT ((0)) NOT NULL,
    [total_redemption_eVoucher]  INT             NULL,
    [full_page_tracker]          INT             NULL,
    [catfish_tracker]            INT             NULL,
    [wink_tag]                   INT             NULL,
    [created_at]                 DATETIME        NULL,
    [customer_id]                INT             NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

