CREATE TABLE [dbo].[spg_earned_points] (
    [id]            INT          IDENTITY (1, 1) NOT NULL,
    [card_type]     INT          NULL,
    [bank]          INT          NULL,
    [business_date] DATETIME     NULL,
    [total_tabs]    INT          NULL,
    [total_points]  INT          NULL,
    [created_at]    DATETIME     NOT NULL,
    [source]        VARCHAR (10) NOT NULL,
    [customer_id]   INT          NOT NULL,
    CONSTRAINT [PK_spg_earned_points] PRIMARY KEY CLUSTERED ([id] ASC)
);

