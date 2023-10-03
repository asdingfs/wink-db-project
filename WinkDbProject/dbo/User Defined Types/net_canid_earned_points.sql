CREATE TYPE [dbo].[net_canid_earned_points] AS TABLE (
    [id]            INT             NOT NULL,
    [can_id]        VARCHAR (50)    NOT NULL,
    [business_date] DATETIME        NOT NULL,
    [total_tabs]    INT             NOT NULL,
    [total_points]  DECIMAL (10, 2) NOT NULL,
    [created_at]    DATETIME        NULL);

