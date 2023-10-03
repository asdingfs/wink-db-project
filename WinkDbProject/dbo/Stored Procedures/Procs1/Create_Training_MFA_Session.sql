CREATE PROCEDURE [dbo].[Create_Training_MFA_Session]
(
	@email varchar(100),
	@campaignId int
)
AS
BEGIN
	DECLARE @id int
	DECLARE @user_id int
	DECLARE @current_datetime datetime
	EXEC GET_CURRENT_SINGAPORT_DATETIME @current_datetime output

	IF(@campaignId IS NULL OR @campaignId = 0)
	BEGIN
		SELECT '0' AS success, 'Please try again later.' as msg, '' as code;
		RETURN
	END

	IF(@email NOT LIKE '%@smrt.com.sg' AND @email NOT LIKE '%@stellarlifestyle.com.sg')
	BEGIN
		SELECT '0' AS success, 'Please enter a valid work email address.' as msg, '' as code;
		RETURN
	END
	
	IF EXISTS (SELECT 1 FROM training_email_wid_link WHERE email like @email AND campaign_id = @campaignId)
	BEGIN
		DECLARE @wid varchar(50);
		DECLARE @customerId int;
		DECLARE @totalQueCount int = 0
		DECLARE @latestLinkDate datetime

		SELECT TOP(1) @wid = wid, @latestLinkDate = created_at
		FROM training_email_wid_link
		WHERE email like @email
		AND campaign_id = @campaignId
		ORDER BY created_at DESC;

		SELECT @customerId = customer_id 
		FROM customer
		WHERE WID like @wid;

		SELECT @totalQueCount = COUNT(question_id) from winktag_survey_question where campaign_id = @campaignId;
		
		IF EXISTS(
			SELECT 1
			FROM winktag_customer_survey_answer_detail
			WHERE campaign_id = @campaignId
			AND customer_id = @customerId
			AND created_at > @latestLinkDate
		)
		BEGIN
			IF(
				(
					SELECT COUNT(*) 
					FROM winktag_customer_survey_answer_detail
					WHERE campaign_id = @campaignId
					AND customer_id = @customerId
					AND created_at > @latestLinkDate
				)<@totalQueCount
			)
			BEGIN
				SELECT '0' AS success, 'The WID associated with this email account is already activated. You may proceed to WINK+ PLAY to complete the WINK+ Refresher quiz.' as msg, '' as code;
				RETURN
			END
		END
	END
			
	IF NOT EXISTS(SELECT id from training_mfa_session where [status] = 0 and @current_datetime <= expired_at and email like @email and campaign_id = @campaignId)
	BEGIN
		declare @random int;
		declare @lower int;
		declare @upper int;
		declare @expired_at datetime;

		set @lower  = 1000; --The lowest random number
		set @upper  = 9999; --The highest random number
		SELECT @random = ROUND(((@upper - @lower -1) * RAND() + @lower), 0)

		WHILE  EXISTS (SELECT * FROM training_mfa_session WHERE session_code = @random and expired_at >= @current_datetime and campaign_id = @campaignId)
		BEGIN
			SELECT @random = ROUND(((@upper - @lower -1) * RAND() + @lower), 0)
		END

		SELECT @expired_at = DATEADD(MINUTE,system_value,@current_datetime)FROM system_key_value WHERE system_key = 'session_code_validity'
				
				

		INSERT INTO [dbo].[training_mfa_session]
           ([email]
           ,[session_code]
		   ,[campaign_id]
           ,[created_at]
           ,[expired_at]
           ,[status])
		VALUES
			(@email
			,@random
			,@campaignId
			,@current_datetime
			,@expired_at
			,0);
	
		IF(@@ROWCOUNT > 0)
		BEGIN		
			SELECT '1' AS success, 'A verification code has been sent to your work email account.' as msg, @random as code;
			RETURN
		END
	END
	ELSE
	BEGIN
					
		SELECT '2' AS success, 'We have already sent you a verification code.' as msg, '' as code;
		RETURN
	END
END