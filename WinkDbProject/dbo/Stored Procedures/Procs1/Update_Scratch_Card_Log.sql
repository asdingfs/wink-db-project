
CREATE PROC [dbo].[Update_Scratch_Card_Log]
@campaign_id int,
@customer_id int,
@inventoryCount int

AS 

BEGIN
DECLARE @CURRENT_DATETIME Datetime ;     
EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUTPUT 
	
	--1)CHECK CUSTOMER
	IF NOT EXISTS (SELECT * FROM VW_ACTIVE_CUSTOMER WHERE customer_id = @customer_id)
	BEGIN
		SELECT '0' AS response_code, 'Invalid Customer' as response_message;
		return
	END

	--2)CHECK CAMPAIGN
	IF NOT EXISTS (SELECT * FROM VW_ACTIVE_WINKTAG_CAMPAIGN WHERE campaign_id = @campaign_id)
	BEGIN
		SELECT '0' AS response_code, 'Invalid Campaign' as response_message;
		return
	END


	DECLARE @winnerCount int
	DECLARE @curAns varchar(100)



	SELECT @winnerCount = 
			COUNT(*) FROM winktag_customer_survey_answer_detail 
			where campaign_id = @campaign_id and cast (created_at as date) = cast(@CURRENT_DATETIME as date) and answer = 'Yes'
			and customer_id not in (
				select e.customer_id 
				FROM winktag_customer_earned_points as e
				where e.campaign_id = @campaign_id and cast (e.created_at as date) = cast(@CURRENT_DATETIME as date)
				and additional_point_status = 1
			);

	IF(@winnerCount = @inventoryCount)
	BEGIN
		UPDATE winktag_customer_survey_answer_detail
		set answer = 'No'
		where customer_id = @customer_id
		AND campaign_id = @campaign_id
		AND cast(created_at as date) = cast(@CURRENT_DATETIME as date);
	END


	UPDATE [dbo].[winktag_customer_action_log]
	set survey_complete_status = 1
	where customer_id = @customer_id
	AND campaign_id = @campaign_id
	AND cast(created_at as date) = cast(@CURRENT_DATETIME as date);

	UPDATE winktag_customer_earned_points
	set additional_point_status = 0, created_at = @CURRENT_DATETIME
	where customer_id = @customer_id
	AND campaign_id = @campaign_id
	AND cast(created_at as date) = cast(@CURRENT_DATETIME as date);

	SELECT @curAns = answer from
	winktag_customer_survey_answer_detail
	where customer_id = @customer_id
	AND campaign_id = @campaign_id
	AND cast(created_at as date) = cast(@CURRENT_DATETIME as date);

	IF(@curAns like 'Yes')
	BEGIN
		SELECT '1' AS response_code, 'Yes' as response_message;
			return
	END
	ELSE IF(@curAns like 'No')
	BEGIN
		SELECT '1' AS response_code, 'No' as response_message;
			return
	END

	
	
END
