CREATE TABLE [dbo].[hof_luckydraw_old] (
    [id]          INT           IDENTITY (1, 1) NOT NULL,
    [qr_code]     VARCHAR (100) NULL,
    [customer_id] INT           NOT NULL,
    [created_at]  DATETIME      NULL,
    [updated_at]  DATETIME      NULL,
    [prize]       VARCHAR (250) NULL
);

