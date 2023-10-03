CREATE TABLE [dbo].[customer_login_withPasswordAndPhone] (
    [id]                             INT      IDENTITY (1, 1) NOT NULL,
    [customer_sub_activation_status] INT      DEFAULT ((0)) NOT NULL,
    [created_at]                     DATETIME NULL,
    [customer_id]                    INT      NOT NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

