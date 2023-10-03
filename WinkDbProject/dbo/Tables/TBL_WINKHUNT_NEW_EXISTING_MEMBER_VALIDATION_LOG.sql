CREATE TABLE [dbo].[TBL_WINKHUNT_NEW_EXISTING_MEMBER_VALIDATION_LOG] (
    [id]          INT          IDENTITY (1, 1) NOT NULL,
    [wid]         VARCHAR (10) NOT NULL,
    [fulfillment] VARCHAR (10) NOT NULL,
    [member_type] VARCHAR (10) NOT NULL,
    [created_at]  DATETIME     NOT NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

