CREATE TABLE [dbo].[hof_luckydraw] (
    [id]          INT           IDENTITY (1, 1) NOT NULL,
    [qr_code]     VARCHAR (100) NULL,
    [customer_id] INT           NOT NULL,
    [created_at]  DATETIME      NULL,
    [updated_at]  DATETIME      NULL,
    [prize]       VARCHAR (250) NULL,
    [event_name]  VARCHAR (250) NULL,
    [start_date]  VARCHAR (100) NULL,
    [end_date]    VARCHAR (100) NULL,
    [qty]         INT           NULL
);

