CREATE TABLE [dbo].[wink_thirdparty_referral] (
    [id]            INT           IDENTITY (1, 1) NOT NULL,
    [campaignId]    INT           NULL,
    [refereeCid]    INT           NULL,
    [refereePts]    INT           NULL,
    [location]      VARCHAR (200) NULL,
    [ip]            VARCHAR (30)  NULL,
    [referralCode]  VARCHAR (12)  NULL,
    [referrerWid]   VARCHAR (50)  NULL,
    [referrerCid]   INT           NULL,
    [referrerName]  VARCHAR (201) NULL,
    [referrerEmail] VARCHAR (200) NULL,
    [referrerPts]   INT           NULL,
    [createdOn]     DATETIME      NULL,
    CONSTRAINT [PK_wink_thirdparty_referral] PRIMARY KEY CLUSTERED ([id] ASC)
);

