CREATE TABLE [dbo].[referral] (
    [referral_id]            INT           IDENTITY (1, 1) NOT NULL,
    [referrer_customer_id]   INT           NOT NULL,
    [referee_customer_id]    INT           NOT NULL,
    [referrer_earned_points] INT           NOT NULL,
    [referee_earned_points]  INT           NOT NULL,
    [referral_code]          VARCHAR (50)  NULL,
    [reward_type]            VARCHAR (100) NULL,
    [reward_date]            DATETIME      NOT NULL,
    PRIMARY KEY CLUSTERED ([referral_id] ASC)
);

