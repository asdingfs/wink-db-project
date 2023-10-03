
CREATE PROCEDURE [dbo].[Game_Update_TeamPlayers_ByTeam]
(
@TableVar as GameTableVariableUpdate readonly,
@team_name VARCHAR(255),
@event_date_id int,
@invoice_id VARCHAR(255),
@team_id int
)
AS

DECLARE @invalid_customer varchar(255)
DECLARE @duplicate_customer varchar(255)

BEGIN

	IF EXISTS (SELECT * FROM game_team WHERE team_id =@team_id)
	BEGIN
		
		IF NOT EXISTS (SELECT * FROM game_team WHERE team_name = @team_name AND team_id <> @team_id)
		BEGIN
			UPDATE game_team SET team_name = @team_name, event_date_id = @event_date_id,event_date=(SELECT event_date from game_event_date where event_date_id = @event_date_id),updated_date = GETDATE()
			WHERE team_id = @team_id
			
			/*declare @team_player_id int
			declare curr cursor local for select team_player_id from @TableVar
			
			OPEN curr
			FETCH NEXT FROM curr INTO @team_player_id

			WHILE (@@FETCH_STATUS = 0)
			BEGIN
				--select * from game_team_players_details
				
				Declare @email varchar(50)
				
				SET @email = (SELECT email from @TableVar where team_player_id = @team_player_id)
				
				IF EXISTS(SELECT * FROM customer WHERE STATUS = 'enable' AND email = @email)
				BEGIN
					IF NOT EXISTS (SELECT * FROM game_team_players_details WHERE email = @email and event_date_id = @event_date_id and team_id <> @team_id)
					BEGIN
						UPDATE game_team_players_details SET event_date_id = @event_date_id, customer_id = (SELECT team_player_id FROM @TableVar WHERE team_player_id = @team_player_id),email = (SELECT email FROM @TableVar WHERE team_player_id = @team_player_id),first_name = (SELECT first_name FROM @TableVar WHERE team_player_id = @team_player_id),last_name = (SELECT last_name FROM @TableVar WHERE team_player_id = @team_player_id),updated_date = GETDATE() WHERE team_player_id = @team_player_id
					END
					ELSE
					BEGIN
						SET @duplicate_customer = @email + ' ' 
					END
				END
				ELSE
				BEGIN
					SET @invalid_customer = @email + ' '
				END
				
				FETCH NEXT FROM curr INTO @team_player_id
			END
			close curr
			deallocate curr*/
			
			declare @team_player_id int
			declare curr cursor local for select team_player_id from @TableVar
			
			OPEN curr
			FETCH NEXT FROM curr INTO @team_player_id

			WHILE (@@FETCH_STATUS = 0)
			BEGIN
				--select * from game_team_players_details

				UPDATE game_team_players_details 
				SET event_date_id = @event_date_id, customer_id = (SELECT customer_id FROM @TableVar WHERE team_player_id = @team_player_id),email = (SELECT email FROM @TableVar WHERE team_player_id = @team_player_id),first_name = (SELECT first_name FROM @TableVar WHERE team_player_id = @team_player_id),last_name = (SELECT last_name FROM @TableVar WHERE team_player_id = @team_player_id),updated_date = GETDATE() WHERE team_player_id = @team_player_id
				
				FETCH NEXT FROM curr INTO @team_player_id
			END
			close curr
			deallocate curr
			
			SELECT '1' as response_code, 'Success' as response_message
			return;
					
		END
		ELSE
		BEGIN
			SELECT '0' as response_code, 'Team name already exists' as response_message
			return;
		END
		 
	END
	ELSE
	BEGIN
		SELECT '0' as response_code, 'Invalid team' as response_message
		return;
	END

END


	





