CREATE TABLE [dbo].[wink_white_ip_list] (
    [id]            INT          IDENTITY (1, 1) NOT NULL,
    [admin_user_id] INT          NOT NULL,
    [type]          VARCHAR (50) NOT NULL,
    [ip_address]    VARCHAR (50) NOT NULL,
    [status]        VARCHAR (10) DEFAULT ('0') NOT NULL,
    [created_at]    DATETIME     NULL,
    [updated_at]    DATETIME     NULL
);

