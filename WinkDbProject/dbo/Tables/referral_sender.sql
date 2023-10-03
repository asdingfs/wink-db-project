CREATE TABLE [dbo].[referral_sender] (
    [sender_id]   INT          IDENTITY (1, 1) NOT NULL,
    [customer_id] INT          NOT NULL,
    [email]       VARCHAR (50) NOT NULL,
    [created_at]  DATETIME     NULL,
    [updated_at]  DATETIME     NULL,
    [event_name]  VARCHAR (50) NULL
);

