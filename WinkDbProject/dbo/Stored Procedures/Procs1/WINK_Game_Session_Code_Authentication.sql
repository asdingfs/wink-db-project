
CREATE PROCEDURE [dbo].[WINK_Game_Session_Code_Authentication]
(	@campaign_id int,
	@pin int,
	@customer_id int,
	@location varchar(250),
	@ip_address varchar(50)
)
AS
BEGIN

	DECLARE @CURRENT_DATETIME Datetime ;     
	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUTPUT 

	declare @session_id int

	SELECT TOP(1) @session_id = id from wink_game_session 
	where pin = @pin 
	and expired_at >= @CURRENT_DATETIME
	and campaign_id = @campaign_id
	order by expired_at desc;

	IF(@session_id is not null or @session_id != 0)
	BEGIN

		DECLARE @characterNum int
		
		-- check how many times user has participated
		IF(@campaign_id = 165)
		BEGIN
			DECLARE @campaignEndedMsg varchar(200) = 'WINK+ CITY is now closed. Please stay tuned for our future campaigns! Thank you for visiting and see you again soon!'
			IF NOT EXISTS(SELECT * FROM VW_ACTIVE_WINKTAG_CAMPAIGN WHERE CAMPAIGN_ID = @campaign_id)
			BEGIN
				SELECT '2' as response_code, @campaignEndedMsg as response_message, @session_id as session_id
				RETURN
			END

			IF(cast(@CURRENT_DATETIME as time) between '00:00:00.000' and '05:29:59.999')
			BEGIN
				IF(cast(@CURRENT_DATETIME as date) < '2021-06-30')
				BEGIN
					SELECT '2' as response_code, 'WINK+ CITY is now closed for the day. Please visit us again between 530am and 1159pm. Thank you.' as response_message, @session_id as session_id
					RETURN
				END
				ELSE
				BEGIN
					SELECT '2' as response_code, @campaignEndedMsg as response_message, @session_id as session_id
					RETURN
				END
			END

			-- WINK WFH 2021
			IF ((select count(1) from wink_game_customer_result where campaign_id = @campaign_id and customer_id = @customer_id and cast(created_at as date) = cast(@CURRENT_DATETIME as date))>=6)
			BEGIN
				SELECT '2' as response_code, 'Thank you! You have already participated in today''s game.' as response_message, @session_id as session_id
				return
			END
		END
		ELSE IF(@campaign_id = 134)
		BEGIN
			-- WINK City POC
			IF ((select count(1) from wink_game_customer_result where campaign_id = @campaign_id and customer_id = @customer_id and session_id = @session_id)>=4)
			BEGIN
				SELECT '2' as response_code, 'Thank you! You have already participated for this round.' as response_message, @session_id as session_id
				return
			END
		END

		
		IF @location is null or @location = '' or @location = '(null)'
		BEGIN
			SET @location = 'User location cannot be detected';
		END
			
		declare @hasLogRecord int = 0;
	
		IF(@campaign_id = 165)
		BEGIN
			IF EXISTS (select 1 from wink_game_customer_log where campaign_id = @campaign_id and customer_id = @customer_id and cast(created_at as date) = cast(@CURRENT_DATETIME as date))
			BEGIN
				
				SELECT Top(1) @characterNum = [character]
				from wink_game_customer_log 
				where campaign_id = @campaign_id 
				AND customer_id = @customer_id 
				AND cast(created_at as date) = cast(@CURRENT_DATETIME as date)
				ORDER BY created_at desc;

				
				IF EXISTS(select 1 from wink_game_customer_log where campaign_id = @campaign_id and customer_id = @customer_id and cast(created_at as date) = cast(@CURRENT_DATETIME as date) AND survey_complete_status = 1)
				BEGIN
					set @hasLogRecord = 1;
				END
			END
			ELSE
			BEGIN
				set @characterNum = (SELECT FLOOR(RAND()*(4-1+1)+1));
			END
		END
		ELSE IF(@campaign_id = 134)
		BEGIN
			IF EXISTS (select 1 from wink_game_customer_log where campaign_id = @campaign_id and customer_id = @customer_id and session_id = @session_id)
			BEGIN
				set @hasLogRecord = 1;
				set @characterNum = (SELECT Top(1) [character] from wink_game_customer_log where campaign_id = @campaign_id and customer_id = @customer_id and session_id = @session_id);
			END
			ELSE
			BEGIN
				set @characterNum = (SELECT FLOOR(RAND()*(4-1+1)+1));
			END
		END
			
		INSERT INTO [dbo].[wink_game_customer_log]
				([session_id]
				,[customer_id]
				,[campaign_id]
				,[ip_address]
				,[gps_location]
				,[created_at]
				,[survey_complete_status]
				,[character])
			VALUES
				(@session_id
				,@customer_id
				,@campaign_id
				,@ip_address
				,@location
				,@CURRENT_DATETIME
				,@hasLogRecord
				,@characterNum);
		IF(@@ROWCOUNT>0)
		BEGIN

			SELECT '1' as response_code, @hasLogRecord as response_message, @session_id as session_id
			return
		END

		

	END
	ELSE
	BEGIN
		SELECT '0' as response_code, 'Invalid code' as response_message, @session_id as session_id
		return
	END

	

	

	
END
	




