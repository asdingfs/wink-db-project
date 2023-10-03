CREATE TABLE [dbo].[wink_thirdparty_referral_codes] (
    [id]           INT          IDENTITY (1, 1) NOT NULL,
    [campaignId]   INT          NOT NULL,
    [parentId]     INT          NOT NULL,
    [referralCode] VARCHAR (12) NOT NULL,
    [usedStatus]   INT          NOT NULL,
    [updatedAt]    DATETIME     NOT NULL,
    [createdAt]    DATETIME     NOT NULL,
    CONSTRAINT [PK_wink_thirdparty_referral_codes] PRIMARY KEY CLUSTERED ([id] ASC)
);

