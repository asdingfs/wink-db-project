CREATE PROC Game_GetTeamByInvoiceID
(
@invoice_id varchar(50)
)

AS

DECLARE @TEAM_ID AS INT

BEGIN
	IF EXISTS (SELECT * FROM game_team WHERE invoice_id = @invoice_id)
	BEGIN
		SET @TEAM_ID = (SELECT TEAM_ID FROM game_team WHERE invoice_id = @invoice_id)
		SELECT '1' as response_code, 'Success' as response_message, @TEAM_ID as team_id
		RETURN;
	END
	ELSE
	BEGIN
		SELECT '0' as response_code, 'Invalid Invoice ID' as response_message
		RETURN;
	END
END
