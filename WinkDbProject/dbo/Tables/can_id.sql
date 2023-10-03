CREATE TABLE [dbo].[can_id] (
    [id]             INT           IDENTITY (1, 1) NOT NULL,
    [customer_id]    INT           NOT NULL,
    [created_at]     DATETIME      NULL,
    [updated_at]     DATETIME      NULL,
    [customer_canid] VARCHAR (100) NULL,
    [can_id_key]     VARCHAR (100) NULL,
    [card_tag]       VARCHAR (20)  NULL,
    [status]         VARCHAR (10)  CONSTRAINT [DF__can_id__status__5A1A5A11] DEFAULT ('enable') NOT NULL,
    CONSTRAINT [PK__can_id__3213E83FEEFEFC15] PRIMARY KEY CLUSTERED ([id] ASC),
    CONSTRAINT [customer_canid] UNIQUE NONCLUSTERED ([customer_canid] ASC)
);

