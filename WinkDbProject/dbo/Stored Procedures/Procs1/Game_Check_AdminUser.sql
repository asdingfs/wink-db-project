CREATE PROCEDURE Game_Check_AdminUser
(
	@email varchar(255),
	@password varchar(255)
)
AS
BEGIN
	IF EXISTS(SELECT * FROM GAME_ADMIN_USER WHERE EMAIL = @email AND PASSWORD = @password)
	BEGIN
		SELECT '1' as response_code, 'success' as response_message
		RETURN;
	END
	ELSE
	BEGIN
		SELECT '0' as response_code, 'Invalid admin user' as response_message
		RETURN;
	END
END