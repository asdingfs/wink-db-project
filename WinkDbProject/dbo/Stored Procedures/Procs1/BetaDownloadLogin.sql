-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE BetaDownloadLogin
	@email VARCHAR(150),
    @password varchar(150),
	@type varchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF EXISTS(SELECT * FROM beta_download WHERE email = @email AND password = @password AND type = @type)
    SELECT 'true' AS UserExists
ELSE
    SELECT 'false' AS UserExists
END
