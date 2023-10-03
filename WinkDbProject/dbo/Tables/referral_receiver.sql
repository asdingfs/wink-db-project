CREATE TABLE [dbo].[referral_receiver] (
    [receiver_id]    INT           IDENTITY (1, 1) NOT NULL,
    [referral_email] VARCHAR (100) NOT NULL,
    [sender_id]      INT           NOT NULL,
    [customer_id]    INT           NOT NULL,
    [created_at]     DATETIME      NULL,
    [updated_at]     DATETIME      NULL,
    [event_name]     VARCHAR (100) NULL
);

