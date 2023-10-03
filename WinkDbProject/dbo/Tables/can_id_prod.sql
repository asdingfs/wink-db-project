CREATE TABLE [dbo].[can_id_prod] (
    [id]              INT           NOT NULL,
    [customer_id]     INT           NOT NULL,
    [created_at]      DATETIME      NULL,
    [updated_at]      DATETIME      NULL,
    [customer_canid]  VARCHAR (100) NULL,
    [can_id_prod_key] VARCHAR (50)  NULL,
    [status]          VARCHAR (10)  DEFAULT ('enable') NOT NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

