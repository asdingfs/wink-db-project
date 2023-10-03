CREATE TABLE [dbo].[customer_enquiry] (
    [id]           INT           IDENTITY (1, 1) NOT NULL,
    [phone_no]     VARCHAR (10)  NULL,
    [email]        VARCHAR (200) NOT NULL,
    [message]      VARCHAR (MAX) NULL,
    [ip_address]   VARCHAR (20)  NULL,
    [GPS_location] VARCHAR (200) NULL,
    [app_version]  VARCHAR (50)  NULL,
    [created_at]   DATETIME      NOT NULL,
    CONSTRAINT [PK_customer_enquiry] PRIMARY KEY CLUSTERED ([id] ASC)
);

