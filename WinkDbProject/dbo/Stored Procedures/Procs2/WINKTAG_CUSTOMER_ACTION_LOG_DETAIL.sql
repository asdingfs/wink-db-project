
CREATE PROC [dbo].[WINKTAG_CUSTOMER_ACTION_LOG_DETAIL]
@campaign_id int,
@customer_id int,
@location varchar(250),
@ip_address varchar(50)

AS 

BEGIN

	DECLARE @SURVEY_COMPLETE_STATUS BIT = 0
	--1)CHECK CUSTOMER
	IF NOT EXISTS (SELECT * FROM VW_ACTIVE_CUSTOMER WHERE customer_id = @customer_id)
	BEGIN
		SELECT '0' AS response_code, 'Invalid Customer' as response_message
		return
	END

	--2)CHECK CAMPAIGN
	IF NOT EXISTS (SELECT * FROM VW_ACTIVE_WINKTAG_CAMPAIGN WHERE campaign_id = @campaign_id)
	BEGIN
		SELECT '0' AS response_code, 'Invalid Campaign' as response_message
		return
	END

	IF @location is null or @location = '' or @location = '(null)'
		SET @location = 'User location cannot be detected'

	/*
	IF (@campaign_id = 157)
	BEGIN
		SET @SURVEY_COMPLETE_STATUS = 0
		IF  NOT EXISTS(SELECT * FROM winktag_customer_survey_answer_detail WHERE customer_id = @customer_id AND campaign_id = @campaign_id)
		BEGIN
		
			INSERT INTO [dbo].[winktag_customer_action_log]
           ([customer_id]
           ,[campaign_id]
           ,[customer_action]
           ,[ip_address]
           ,[location]
		   ,[survey_complete_status]
           ,[created_at])
			VALUES
			 (@customer_id,@campaign_id,(SELECT winktag_type FROM winktag_campaign WHERE campaign_id = @campaign_id),@ip_address,@location,@SURVEY_COMPLETE_STATUS,(SELECT TODAY FROM VW_CURRENT_SG_TIME)) 
		END
	END
	ELSE
	
	BEGIN
	*/
	IF EXISTS(
		SELECT * FROM winktag_customer_earned_points WHERE customer_id = @customer_id AND campaign_id = @campaign_id
		AND ( 
				(
					@campaign_id != 175 
					AND @campaign_id != 146 
					--AND @campaign_id !=174
					AND @campaign_id != 187
					AND @campaign_id != 189
					AND @campaign_id != 191
					AND @campaign_id != 194
					AND @campaign_id != 197
					AND @campaign_id != 198
					AND @campaign_id != 199
					AND @campaign_id != 200
					AND @campaign_id != 201
                    AND @campaign_id != 204
                    AND @campaign_id != 208
                    AND @campaign_id != 210
                    AND @campaign_id != 215
					AND @campaign_id != 217
					AND @campaign_id != 218
				)  
				or 
				(@campaign_id = 175 and cast(created_at as date) = cast((SELECT TODAY FROM VW_CURRENT_SG_TIME) as date))
				--or 
				--(@campaign_id = 174 and cast(created_at as date) = cast((SELECT TODAY FROM VW_CURRENT_SG_TIME) as date))
				or 
				(@campaign_id = 146 and cast(created_at as date) = cast((SELECT TODAY FROM VW_CURRENT_SG_TIME) as date))
				or 
				(@campaign_id = 187 and cast(created_at as date) = cast((SELECT TODAY FROM VW_CURRENT_SG_TIME) as date))
				or 
				(@campaign_id = 189 and cast(created_at as date) = cast((SELECT TODAY FROM VW_CURRENT_SG_TIME) as date))
				or 
				(@campaign_id = 191 and cast(created_at as date) = cast((SELECT TODAY FROM VW_CURRENT_SG_TIME) as date))
				or 
				(@campaign_id = 194 and cast(created_at as date) = cast((SELECT TODAY FROM VW_CURRENT_SG_TIME) as date))
				or 
				(@campaign_id = 197 and cast(created_at as date) = cast((SELECT TODAY FROM VW_CURRENT_SG_TIME) as date))
				or 
				(@campaign_id = 198 and cast(created_at as date) = cast((SELECT TODAY FROM VW_CURRENT_SG_TIME) as date))
				or 
				(@campaign_id = 199 and cast(created_at as date) = cast((SELECT TODAY FROM VW_CURRENT_SG_TIME) as date))
				or 
				(@campaign_id = 200 and cast(created_at as date) = cast((SELECT TODAY FROM VW_CURRENT_SG_TIME) as date))
				or 
				(@campaign_id = 201 and cast(created_at as date) = cast((SELECT TODAY FROM VW_CURRENT_SG_TIME) as date))
                or 
				(@campaign_id = 204 and cast(created_at as date) = cast((SELECT TODAY FROM VW_CURRENT_SG_TIME) as date))
                or 
				(@campaign_id = 208 and cast(created_at as date) = cast((SELECT TODAY FROM VW_CURRENT_SG_TIME) as date))
                or 
				(@campaign_id = 210 and cast(created_at as date) = cast((SELECT TODAY FROM VW_CURRENT_SG_TIME) as date))
                or 
				(@campaign_id = 215 and cast(created_at as date) = cast((SELECT TODAY FROM VW_CURRENT_SG_TIME) as date))
				 or 
				(@campaign_id = 217 and cast(created_at as date) = cast((SELECT TODAY FROM VW_CURRENT_SG_TIME) as date))
				or 
				(@campaign_id = 218 and cast(created_at as date) = cast((SELECT TODAY FROM VW_CURRENT_SG_TIME) as date))
                
		)
	)
	BEGIN
		SET @SURVEY_COMPLETE_STATUS = 1
	END



	IF(@campaign_id = 169)
	BEGIN
		DECLARE @wid varchar(50);
		DECLARE @latestLinkDate datetime

		SELECT @wid = WID 
		FROM customer
		WHERE customer_id = @customer_id;

		SELECT TOP(1) @latestLinkDate = created_at
		FROM training_email_wid_link
		WHERE wid like @wid
		AND campaign_id = @campaign_id
		ORDER BY created_at DESC;

		IF(
			(
				SELECT COUNT(*) 
				FROM winktag_customer_survey_answer_detail
				WHERE campaign_id = @campaign_id
				AND customer_id = @customer_id
				AND created_at > @latestLinkDate
			) = 0
		)
		BEGIN
			SET @SURVEY_COMPLETE_STATUS = 0;	
		END
	END
    ELSE IF (@campaign_id = 211 or @campaign_id = 212 or @campaign_id = 215 )
    BEGIN
        IF EXISTS(SELECT 1 from TBL_WINKPLAY_WINKHUNT_CUSTOMER_CODES_LOG AS L
        JOIN TBL_WINKPLAY_WINKHUNT_CODES AS C
        ON L.WP_WH_CODES_ID = C.WP_WH_CODES_ID
        WHERE L.customer_id = @customer_id AND C.campaign_id = @campaign_id)
        BEGIN
            SET @SURVEY_COMPLETE_STATUS = 1
        END
    END

	print(@SURVEY_COMPLETE_STATUS)
	INSERT INTO [dbo].[winktag_customer_action_log]
           ([customer_id]
           ,[campaign_id]
           ,[customer_action]
           ,[ip_address]
           ,[location]
		   ,[survey_complete_status]
           ,[created_at])
     VALUES
           (@customer_id,@campaign_id,(SELECT winktag_type FROM winktag_campaign WHERE campaign_id = @campaign_id),@ip_address,@location,@SURVEY_COMPLETE_STATUS,(SELECT TODAY FROM VW_CURRENT_SG_TIME)) 
	-- END
END
