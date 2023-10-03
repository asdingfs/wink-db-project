CREATE TABLE [dbo].[Winktag_Lucky_Draw] (
    [winktag_lucky_draw_id]   INT           IDENTITY (1, 1) NOT NULL,
    [qr_code_value]           VARCHAR (100) NOT NULL,
    [created_by]              INT           NULL,
    [created_at]              DATETIME      NULL,
    [updated_at]              DATETIME      NULL,
    [winner_id]               VARCHAR (MAX) NULL,
    [winktag_lucky_draw_name] VARCHAR (250) NULL,
    [lucky_draw_status]       INT           NULL,
    [success_msg]             VARCHAR (250) NULL,
    [failed_attempt_msg]      VARCHAR (250) NULL,
    [invalid_msg]             VARCHAR (250) NULL,
    CONSTRAINT [PK__Winktag___218EC23724DF3348] PRIMARY KEY CLUSTERED ([winktag_lucky_draw_id] ASC)
);

