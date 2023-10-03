CREATE TABLE [dbo].[event_customer_details] (
    [id]            INT           IDENTITY (1, 1) NOT NULL,
    [team_id]       INT           NOT NULL,
    [customer_id]   INT           NOT NULL,
    [email]         VARCHAR (255) NOT NULL,
    [first_name]    VARCHAR (255) NOT NULL,
    [last_name]     VARCHAR (255) NOT NULL,
    [active_status] BIT           NOT NULL,
    [created_date]  DATETIME      NULL,
    [updated_date]  DATETIME      NULL
);

