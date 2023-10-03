CREATE TABLE [dbo].[referral_program_config] (
    [program_id]          INT           IDENTITY (1, 1) NOT NULL,
    [points_for_referrer] INT           NOT NULL,
    [points_for_referee]  INT           NOT NULL,
    [reward_type]         VARCHAR (100) NOT NULL,
    [size]                INT           NOT NULL,
    [status]              INT           NOT NULL,
    [from_date]           DATETIME      NULL,
    [to_date]             DATETIME      NULL,
    UNIQUE NONCLUSTERED ([reward_type] ASC)
);

