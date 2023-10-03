CREATE TABLE [dbo].[game_animal] (
    [id]         INT          IDENTITY (1, 1) NOT NULL,
    [animal]     VARCHAR (50) NOT NULL,
    [status]     VARCHAR (10) NOT NULL,
    [created_at] DATETIME     NULL,
    [updated_at] DATETIME     NULL
);

