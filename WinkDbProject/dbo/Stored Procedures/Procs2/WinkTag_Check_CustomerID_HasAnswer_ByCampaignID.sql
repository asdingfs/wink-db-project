
CREATE PROCEDURE [dbo].[WinkTag_Check_CustomerID_HasAnswer_ByCampaignID]
	(@campaign_id int,
     @customer_id int
	 )
AS
DECLARE @CURRENT_DATETIME Datetime ;     
EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUTPUT 
BEGIN
	IF(@campaign_id = 175)
	BEGIN
		IF EXISTS (select 1 from winktag_customer_earned_points 
		where campaign_id = @campaign_id 
		and customer_id = @customer_id 
		and cast(created_at as date) = cast(@CURRENT_DATETIME as date))
		BEGIN
			SELECT 1 AS success , 'WINK+ points redemption limit met for the day' AS response_message
			RETURN
		END
	END
	ELSE IF(@campaign_id = 173)
	BEGIN
		IF EXISTS (select 1 from winktag_customer_earned_points 
		where campaign_id = @campaign_id 
		and customer_id = @customer_id)
		BEGIN
			SELECT 1 AS success , 'Oops! Looks like you have already received your points!' AS response_message
			RETURN
		END
	END
	--ELSE IF(@campaign_id = 174)
	--BEGIN
	--	IF EXISTS (select 1 from winktag_customer_earned_points 
	--	where campaign_id = @campaign_id 
	--	and customer_id = @customer_id 
	--	and cast(created_at as date) = cast(@CURRENT_DATETIME as date))
	--	BEGIN
	--		SELECT 1 AS success , 'Don''t be naughty! You''ve voted! Come another day to vote again!' AS response_message
	--		RETURN
	--	END
	--END
	ELSE IF(@campaign_id = 170)
	BEGIN
		IF EXISTS (select 1 from winktag_customer_survey_answer_detail where campaign_id = @campaign_id and customer_id = @customer_id and answer like '%MC%')
		BEGIN
			SELECT 1 AS success , 'You have already entered a code for this campaign.' AS response_message
			RETURN
		END
	END
	ELSE IF (@campaign_id = 146) 
	BEGIN
		IF EXISTS
		(
			SELECT 1
			FROM nonstop_net_canid_earned_points
			WHERE card_type = '08'  and customer_id= @customer_id and  cast(created_at as date) = cast(@CURRENT_DATETIME as date) 
		)

		BEGIN
			SELECT '1' AS success , 'You have already participated today.<br><br>Participate daily from 23 April to 1 June to earn 5 WINK+ points. ' as response_message
			return
		END
		ELSE
			return
	END
	ELSE IF(@campaign_id = 187)
	BEGIN
		IF EXISTS (select 1 from winktag_customer_earned_points 
		where campaign_id = @campaign_id 
		and customer_id = @customer_id 
		and cast(created_at as date) = cast(@CURRENT_DATETIME as date))
		BEGIN
			SELECT 1 AS success , 'You have already participated today' AS response_message
			RETURN
		END
	END
	-- SMRT 35 Anniversary Phase 1 --
	ELSE IF(@campaign_id = 189)
	BEGIN
		IF EXISTS (select 1 from winktag_customer_earned_points 
		where campaign_id = @campaign_id 
		and customer_id = @customer_id 
		and cast(created_at as date) = cast(@CURRENT_DATETIME as date))
		BEGIN
			SELECT 1 AS success , 'You have already participated today' AS response_message
			RETURN
		END
	END

	-- SMRT35thAnniversaryPhase2,3,4,5,6,7--
	ELSE IF(@campaign_id = 191 OR @campaign_id=194 OR @campaign_id=198 OR @campaign_id=199 OR @campaign_id=200 OR @campaign_id=201)
	BEGIN
		IF EXISTS (select 1 from winktag_customer_earned_points 
		where campaign_id = @campaign_id 
		and customer_id = @customer_id 
		and cast(created_at as date) = cast(@CURRENT_DATETIME as date))
		BEGIN
			SELECT 1 AS success , 'You have already participated today' AS response_message
			RETURN
		END
	END
	-- GreenLiving --
	ELSE IF (@campaign_id = 197)
	BEGIN
		IF EXISTS (select 1 from winktag_customer_earned_points 
		where campaign_id = @campaign_id 
		and customer_id = @customer_id)
		Select 1 as success , 'You have already participated in the survey.' as response_message
		RETURN
	END

    -- Bus Shelter Tender --
	ELSE IF (@campaign_id = 204)
	BEGIN
		IF EXISTS (select 1 from winktag_customer_earned_points 
		where campaign_id = @campaign_id 
		and customer_id = @customer_id)
		Select 1 as success , 'You have already participated in the survey.' as response_message
		RETURN
	END

    -- TownHallHiveSurvey2023 --
	ELSE IF (@campaign_id = 208)
	BEGIN
		IF EXISTS (select 1 from winktag_customer_earned_points 
		where campaign_id = @campaign_id 
		and customer_id = @customer_id)
		Select 1 as success , 'You have already participated in the survey.' as response_message
		RETURN
	END

   --TownHall2023MarsilingStaytion--
	ELSE IF (@campaign_id = 210)
	BEGIN
		IF EXISTS (select 1 from winktag_customer_earned_points 
		where campaign_id = @campaign_id 
		and customer_id = @customer_id)
		Select 1 as success , 'You have already participated in the survey.' as response_message
		RETURN
	END

    --WinkHuntSurveyP1Campaign--
	ELSE IF (@campaign_id = 215)
	BEGIN
		IF EXISTS (select 1 from winktag_customer_earned_points 
		where campaign_id = @campaign_id 
		and customer_id = @customer_id)
		Select 1 as success , 'You have already participated in the survey.' as response_message
		RETURN
	END

	  --WinkHuntSurveyP2Campaign--
	ELSE IF (@campaign_id = 218)
	BEGIN
		IF EXISTS (select 1 from winktag_customer_earned_points 
		where campaign_id = @campaign_id 
		and customer_id = @customer_id)
		Select 1 as success , 'You have already participated in the survey.' as response_message
		RETURN
	END


	ELSE IF (@campaign_id = 167)
	BEGIN
		IF EXISTS (select 1 from winktag_customer_survey_answer_detail where campaign_id = @campaign_id and customer_id = @customer_id)
		Select 1 as success , 'You have already participated in the survey.' as response_message
		RETURN
	END
	ELSE IF EXISTS (select 1 from winktag_customer_earned_points where campaign_id = @campaign_id and customer_id = @customer_id)
	BEGIN
		Select 1 as success , 'You have already participated in the survey.' as response_message
		RETURN
	END
END
	




