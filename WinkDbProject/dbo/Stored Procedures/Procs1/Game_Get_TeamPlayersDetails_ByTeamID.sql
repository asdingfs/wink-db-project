CREATE PROCEDURE Game_Get_TeamPlayersDetails_ByTeamID
(@team_id int
)	
AS
BEGIN
	IF EXISTS(SELECT * FROM game_team WHERE team_id = @team_id)
	BEGIN
		IF EXISTS(SELECT * FROM game_team_players_details WHERE team_id = @team_id)
		BEGIN
			SELECT '1' as response_code, 'Success' as response_message 
			
			SELECT * FROM game_team WHERE team_id = @team_id
		
			SELECT game_team_players_details.*
			FROM game_team
			INNER JOIN game_team_players_details
			ON game_team.team_id = game_team_players_details.team_id and game_team.active_status = 1 and game_team_players_details.active_status = 1 and game_team.team_id = @team_id
			
			
		END
		ELSE
		BEGIN
			SELECT '0' as response_code, 'Team does not exist' as response_message
			RETURN;
		END
	END
	ELSE
	BEGIN
		SELECT '0' as response_code, 'Team does not exist' as response_message
		RETURN; 
	END
END
