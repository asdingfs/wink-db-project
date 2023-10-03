
CREATE PROC [dbo].[WINKTAG_CUSTOMER_ACTION_LOG_Summer_Fun]
@campaign_id int,
@customer_id int,
@location varchar(250),
@ip_address varchar(50)

AS 

BEGIN

	DECLARE @SURVEY_COMPLETE_STATUS BIT = 0

	DECLARE @CURRENT_DATETIME Datetime ;     
	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUTPUT 

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

	IF EXISTS(SELECT * FROM winktag_customer_survey_answer_detail WHERE customer_id = @customer_id AND campaign_id = @campaign_id and cast(created_at as date) = cast(@CURRENT_DATETIME as date))
	BEGIN
		SET @SURVEY_COMPLETE_STATUS = 1;
	END

	INSERT INTO [dbo].[winktag_customer_action_log]
           ([customer_id]
           ,[campaign_id]
           ,[customer_action]
           ,[ip_address]
           ,[location]
		   ,[survey_complete_status]
           ,[created_at])
     VALUES
           (@customer_id,@campaign_id,(SELECT winktag_type FROM winktag_campaign WHERE campaign_id = @campaign_id),@ip_address,@location,@SURVEY_COMPLETE_STATUS,@CURRENT_DATETIME) 
END
