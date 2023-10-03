CREATE TABLE [dbo].[wink_gate_asset] (
    [id]               INT            IDENTITY (1, 1) NOT NULL,
    [gate_id]          VARCHAR (100)  NOT NULL,
    [description]      VARCHAR (250)  NOT NULL,
    [latitude]         VARCHAR (50)   NOT NULL,
    [longitude]        VARCHAR (50)   NOT NULL,
    [range]            INT            NOT NULL,
    [points]           INT            NULL,
    [interval]         INT            NULL,
    [pushHeader]       VARCHAR (250)  NULL,
    [pushMsg]          VARCHAR (500)  NULL,
    [linkTo]           INT            NULL,
    [pin_img]          VARCHAR (1000) NULL,
    [banner_img]       VARCHAR (1000) NULL,
    [banner_hyperlink] VARCHAR (1000) NULL,
    [status]           INT            NULL,
    [created_at]       DATETIME       NOT NULL,
    [updated_at]       DATETIME       NOT NULL,
    CONSTRAINT [PK_wink_gate_asset] PRIMARY KEY CLUSTERED ([id] ASC)
);

