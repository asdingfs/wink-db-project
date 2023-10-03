
CREATE PROCEDURE [dbo].[WINK_Game_Session_Code_Creation]
	(@campaign_id int,
	 @asset_name varchar(100)
	 )
AS
BEGIN

	DECLARE @CURRENT_DATETIME Datetime ;     
	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUTPUT 

	declare @lower int;
	declare @upper int;
	declare @random int;
	declare @currentValidity datetime
	declare @expired_at datetime;
	declare @sessionId int;

	set @lower  = 1000; --The lowest random number
	set @upper  = 9999; --The highest random number

	IF NOT EXISTS (SELECT * FROM VW_ACTIVE_WINKTAG_CAMPAIGN WHERE campaign_id = @campaign_id)
	BEGIN
		IF(@campaign_id = 165)
		BEGIN
			select '0' as response_code, 0 as random_code, '' as wid, 0 as [character]
			return
		END
	END

	SELECT TOP(1) @currentValidity = expired_at, @random = pin, @sessionId = id from wink_game_session 
	where asset_name = @asset_name 
	and campaign_id = @campaign_id
	and cast(expired_at as date) = cast(@CURRENT_DATETIME as date) 
	order by expired_at desc;

	
	IF(@currentValidity is null or @currentValidity < @CURRENT_DATETIME)
	BEGIN
		SELECT @random = ROUND(((@upper - @lower -1) * RAND() + @lower), 0)

		WHILE  EXISTS (SELECT * FROM wink_game_session WHERE pin = @random and cast(created_at as date) = cast(@CURRENT_DATETIME as date))
		BEGIN
			SELECT @random = ROUND(((@upper - @lower -1) * RAND() + @lower), 0)
		END

		SELECT @expired_at = DATEADD(MINUTE,system_value,@CURRENT_DATETIME)FROM system_key_value WHERE system_key = 'session_code_validity'
				
		INSERT INTO [dbo].[wink_game_session]
			   ([campaign_id]
			   ,[asset_name]
			   ,[pin]
			   ,[created_at]
			   ,[expired_at])
		 VALUES
			   (@campaign_id, @asset_name,@random,@CURRENT_DATETIME,@expired_at);
	
		set @sessionId = SCOPE_IDENTITY();

		IF(@@ROWCOUNT>0)
		BEGIN
			select '1' as response_code, @random as random_code, '' as wid, 0 as [character]
			return
		END
    
	END
	ELSE
	BEGIN
		IF EXISTS (
			select c.wid 
			from customer as c, wink_game_customer_log as l
			where l.customer_id = c.customer_id
			and l.campaign_id = @campaign_id
			and l.survey_complete_status = '0'
			and session_id = @sessionId
		)
		BEGIN
			IF(@campaign_id = 165)
			BEGIN
				select TOP(9) '2' as response_code, @random as random_code, c.wid, l.[character] as [character]
				from customer as c, wink_game_customer_log as l
				where l.customer_id = c.customer_id
				and l.survey_complete_status = '0'
				and l.campaign_id = @campaign_id
				and session_id = @sessionId
				GROUP BY c.wid, l.[character] 
				order by max(l.created_at) desc;
				return
			END
			ELSE IF(@campaign_id = 134)
			BEGIN
				select TOP(8) '2' as response_code, @random as random_code, c.wid, l.[character] as [character]
				from customer as c, wink_game_customer_log as l
				where l.customer_id = c.customer_id
				and l.survey_complete_status = '0'
				and l.campaign_id = @campaign_id
				and session_id = @sessionId
				GROUP BY c.wid, l.character 
				order by max(l.created_at) desc;
		
				return
			END
		END
		ELSE
		BEGIN
			select '2' as response_code, @random as random_code, '' as wid, 0 as [character]
			return
		END
	END	
END
