CREATE TABLE [dbo].[points_issuance] (
    [id]              INT           IDENTITY (1, 1) NOT NULL,
    [campaign_id]     INT           NOT NULL,
    [wid]             VARCHAR (50)  NOT NULL,
    [points]          INT           NOT NULL,
    [issuer]          VARCHAR (250) NOT NULL,
    [remark_issuer]   VARCHAR (150) NULL,
    [created_at]      DATETIME      NOT NULL,
    [approver]        VARCHAR (250) NULL,
    [remark_approver] VARCHAR (250) NULL,
    [approved_at]     DATETIME      NULL,
    CONSTRAINT [PK_points_issuance] PRIMARY KEY CLUSTERED ([id] ASC)
);

