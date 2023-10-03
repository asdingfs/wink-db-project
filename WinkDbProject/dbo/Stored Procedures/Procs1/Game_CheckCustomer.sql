CREATE PROCEDURE [dbo].[Game_CheckCustomer]
(@email varchar(255),
@event_date_id INT
)
	
AS
BEGIN
	DECLARE @customer_id varchar(50)

	IF EXISTS(SELECT * FROM customer WHERE STATUS = 'enable' AND email = @email)
	BEGIN
		IF EXISTS(SELECT * FROM game_team_players_details WHERE game_team_players_details.active_status = 1 and email = @email and event_date_id = @event_date_id)
		BEGIN
			SELECT '0' as response_code, @customer_id AS customer_id, 'Duplicate customer' as response_message
			RETURN;
		END
		ELSE
		BEGIN
			SET @customer_id = (SELECT customer_id FROM CUSTOMER WHERE STATUS = 'enable' AND email = @email)
			SELECT '1' as response_code, @customer_id AS customer_id, 'Success' as response_message
			RETURN;
		END
	END
	ELSE
	BEGIN
		SELECT '0' as response_code, @customer_id AS customer_id,'Invalid customer' as response_message
		RETURN;
	END	
END
