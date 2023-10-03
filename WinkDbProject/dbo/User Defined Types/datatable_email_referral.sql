CREATE TYPE [dbo].[datatable_email_referral] AS TABLE (
    [sender_id]      INT           NULL,
    [sender_email]   VARCHAR (255) NULL,
    [referral_email] VARCHAR (255) NULL,
    [created_at]     DATETIME      NULL,
    [updated_at]     DATETIME      NULL);

