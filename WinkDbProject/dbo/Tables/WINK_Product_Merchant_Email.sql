CREATE TABLE [dbo].[WINK_Product_Merchant_Email] (
    [id]            INT            IDENTITY (1, 1) NOT NULL,
    [merchant_id]   INT            NULL,
    [first_line]    VARCHAR (300)  NULL,
    [created_at]    DATETIME       NULL,
    [title]         VARCHAR (200)  NULL,
    [email_message] VARCHAR (3000) NULL,
    CONSTRAINT [PK__WINK_Pro__3213E83F1A04E6AE] PRIMARY KEY CLUSTERED ([id] ASC)
);

