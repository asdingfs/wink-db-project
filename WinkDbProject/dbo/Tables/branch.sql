CREATE TABLE [dbo].[branch] (
    [branch_id]      INT           IDENTITY (1, 1) NOT NULL,
    [branch_name]    VARCHAR (255) NOT NULL,
    [merchant_id]    INT           NOT NULL,
    [created_at]     DATETIME      NULL,
    [updated_at]     DATETIME      NULL,
    [allowed_device] CHAR (10)     CONSTRAINT [DF__branch__allowed___1CBC4616] DEFAULT ('No') NULL,
    [branch_code]    INT           CONSTRAINT [DF__branch__branch_c__1DB06A4F] DEFAULT ((0)) NOT NULL,
    [branch_status]  VARCHAR (50)  NULL,
    CONSTRAINT [PK_Branch] PRIMARY KEY CLUSTERED ([branch_id] ASC),
    CONSTRAINT [UniqueBranchCode] UNIQUE NONCLUSTERED ([branch_code] ASC)
);

