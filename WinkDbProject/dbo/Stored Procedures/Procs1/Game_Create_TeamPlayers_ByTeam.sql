
CREATE PROCEDURE [dbo].[Game_Create_TeamPlayers_ByTeam]
(
@TableVar as GameTableVariable readonly,
@team_name VARCHAR(255),
@event_date_id int,
@invoice_id VARCHAR(255)
)
AS
BEGIN
DECLARE @team_id int

	--CHECK TEAM NAME ALREADY EXISTS OR NOT
	IF EXISTS (SELECT * FROM GAME_TEAM WHERE TEAM_NAME = @team_name)
	BEGIN
		--TEAM NAME ALREADY EXISTS
		SELECT '0' as response_code, @team_name + ' already exists' as response_message
		RETURN;
	END
	ELSE
	BEGIN
		IF EXISTS(SELECT * FROM GAME_TEAM WHERE invoice_id = @invoice_id)
		BEGIN
			SELECT '0' as response_code, 'Invoice ID ' + @invoice_id+ ' already exists' as response_message
			RETURN;
		END
		ELSE
		BEGIN
			--TEAM NAME DOES NOT EXISTS AND CREATE TEAM
			INSERT INTO game_team
			(team_name,event_date_id,event_date,invoice_id,active_status,created_date)
			VALUES
			(@team_name,@event_date_id,(SELECT event_date from game_event_date where event_date_id = @event_date_id),@invoice_id,1,GETDATE())
		    
			IF @@ROWCOUNT > 0
			BEGIN
				SET @team_id = (SELECT TEAM_ID FROM GAME_TEAM WHERE TEAM_NAME = @team_name);
				
				INSERT INTO game_team_players_details
				([team_id],[customer_id],[event_date_id],[email],[first_name],[last_name],[active_status],[created_date])
				SELECT @team_id, customer_id,@event_date_id, email, first_name, last_name,'1',getdate() from @TableVar
				
				IF @@ROWCOUNT > 0
				BEGIN
					SELECT '1' as response_code, @team_name + ' is successfully created' as response_message, @team_id as team_id
					RETURN;
				END
				ELSE
				BEGIN
					SELECT '0' as response_code, @team_name + ' cannot be created' as response_message
					RETURN;
				END
			END
			ELSE
			BEGIN
				SELECT '0' as response_code, @team_name + ' cannot be created' as response_message
				RETURN;
			END
		END
	END
END







