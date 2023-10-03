CREATE TABLE [dbo].[iMOBWINNER_digital_redemption] (
    [id]                INT           IDENTITY (1, 1) NOT NULL,
    [email]             VARCHAR (250) NULL,
    [NRIC]              VARCHAR (100) NULL,
    [phone_no]          VARCHAR (20)  NULL,
    [dob]               VARCHAR (20)  NULL,
    [redemption_status] INT           NOT NULL,
    [event_name]        VARCHAR (100) NULL,
    [created_at]        DATETIME      NULL,
    [customer_id]       INT           NULL,
    [event_type]        VARCHAR (150) NULL,
    [imob_customer_id]  INT           NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

