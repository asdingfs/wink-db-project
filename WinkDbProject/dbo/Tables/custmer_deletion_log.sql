CREATE TABLE [dbo].[custmer_deletion_log] (
    [Id]                        INT            IDENTITY (1, 1) NOT NULL,
    [action_id]                 INT            NULL,
    [customer_id]               INT            NULL,
    [Name]                      VARCHAR (50)   NULL,
    [Email]                     VARCHAR (50)   NULL,
    [CustomerSince]             VARCHAR (50)   NULL,
    [Gender]                    VARCHAR (50)   NULL,
    [Dob]                       VARCHAR (50)   NULL,
    [Card_ID_1]                 VARCHAR (50)   NULL,
    [Card_ID_2]                 VARCHAR (50)   NULL,
    [Card_ID_3]                 VARCHAR (50)   NULL,
    [status]                    VARCHAR (10)   NULL,
    [group_id]                  VARCHAR (10)   NULL,
    [confiscated_wink_status]   VARCHAR (10)   NULL,
    [confiscated_points_status] VARCHAR (255)  DEFAULT ((0)) NULL,
    [locked_reason]             VARCHAR (1000) NULL,
    PRIMARY KEY CLUSTERED ([Id] ASC)
);

