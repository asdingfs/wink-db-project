CREATE PROCEDURE [dbo].[Create_TripleA_Session]
(
	@campaignId int,
	@customerId int
)
AS
BEGIN

 DECLARE @current_datetime datetime
 EXEC GET_CURRENT_SINGAPORT_DATETIME @current_datetime output
 
	IF (@customerId is null or @customerId = '')
	BEGIN
		SELECT '0' AS success, 'Poor network connection. Please try again later.' as msg;
		return
	END

	--1)CHECK CUSTOMER
	IF NOT EXISTS (SELECT * FROM VW_ACTIVE_CUSTOMER WHERE customer_id = @customerId)
	BEGIN
		SELECT '0' AS success,  'Your account is locked. Please contact customer service.' as msg;
		return
	END

	--2)CHECK CAMPAIGN
	IF NOT EXISTS (SELECT * FROM VW_ACTIVE_WINKTAG_CAMPAIGN WHERE campaign_id = @campaignId)
	BEGIN
		SELECT '0' AS success,  'This campaign has ended.' as msg;
		return
	END
	--3)Check if user has already participated in the campaign
	IF EXISTS(SELECT 1 from winktag_customer_survey_answer_detail where campaign_id = @campaignId and customer_id = @customerId)
	BEGIN
		SELECT '0' AS success,  'You have already participated in this campaign.' as msg;
		return
	END

				
	IF NOT EXISTS(
		SELECT 1 from triple_A_session_code 
		where customer_id = @customerId 
		and campaign_id = @campaignId 
		and status = 0 
		and @current_datetime <= expired_at
	)
	BEGIN
		declare @sessionCode varchar(5);
		declare @lower int;
		declare @upper int;
		declare @sessionId int;
		declare @expired_at datetime;

		

		EXEC Get_Session_Code_Triple_A @sessionCode OUTPUT
			
		WHILE EXISTS(SELECT 1 FROM triple_A_session_code WHERE session_code = @sessionCode and campaign_id = @campaignId)
		BEGIN
			EXEC Get_Session_Code_Triple_A @sessionCode OUTPUT
		END

		SELECT @expired_at = DATEADD(MINUTE,system_value,@current_datetime)FROM system_key_value WHERE system_key = 'triple_A_session_validity'
				
		INSERT INTO [dbo].[triple_A_session_code]
				([campaign_id]
				,[customer_id]
				,[session_code]
				,[created_at]
				,[expired_at]
				,[status])
			VALUES
				(@campaignId
				,@customerId
				,@sessionCode
				,@current_datetime
				,@expired_at
				,0)
	
		set @sessionId = SCOPE_IDENTITY();
		IF @@ROWCOUNT > 0
		BEGIN	
			declare @cusEmail varchar(200);
			declare @cusName varchar(100);
			SELECT @cusEmail = email, @cusName = first_name from customer where customer_id = @customerId;

			SELECT '1' AS success, 'A verification code has been sent to your registered email.' as msg, @sessionCode as sessionCode, @cusEmail as cusEmail, @cusName as cusName;
			RETURN
		END
		ELSE
		BEGIN
			SELECT '2' AS success, 'Please try again later.' as msg
			RETURN
		END
	END
	ELSE
	BEGIN
					
		SELECT '2' AS success, 'We have already sent you a verification code.' as msg;
		RETURN
	END
		
 

END