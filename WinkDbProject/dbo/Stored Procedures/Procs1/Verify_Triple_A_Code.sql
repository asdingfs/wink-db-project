CREATE PROCEDURE [dbo].[Verify_Triple_A_Code] 
	(@session_code varchar(5),
	 @campaign_id int,
	 @customer_id int
	 )
AS
BEGIN
	Declare @login_times int
	Declare @verifyCount int
	Declare @current_date datetime
	Declare @admin_user_id int 
	Declare @response_code int

	
	Exec GET_CURRENT_SINGAPORT_DATETIME @current_date output

	IF (@customer_id is null or @customer_id = '')
	BEGIN
		SELECT '0' AS success, 'Poor network connection. Please try again later.' as msg;
		return
	END

	--1)CHECK CUSTOMER
	IF NOT EXISTS (SELECT * FROM VW_ACTIVE_CUSTOMER WHERE customer_id = @customer_id)
	BEGIN
		SELECT '0' AS success,  'Your account is locked. Please contact customer service.' as msg;
		return
	END

	--2)CHECK CAMPAIGN
	IF NOT EXISTS (SELECT * FROM VW_ACTIVE_WINKTAG_CAMPAIGN WHERE campaign_id = @campaign_id)
	BEGIN
		SELECT '0' AS success,  'This campaign has ended.' as msg;
		return
	END

	IF EXISTS (
	SELECT 1 from triple_A_session_code
	where @current_date <= expired_at 
	and campaign_id = @campaign_id
	and customer_id = @customer_id
	and status = 0)
	BEGIN

		IF(@session_code = 
			(SELECT session_code from triple_A_session_code 
			where @current_date <= expired_at 
			and campaign_id = @campaign_id
			and customer_id = @customer_id
			and status = 0 )
		)
		BEGIN
			Update triple_A_session_code 
			set status = 1 
			where campaign_id = @campaign_id
			and session_code = @session_code
			and customer_id = @customer_id;
			IF (@@ROWCOUNT > 0)
			BEGIN
				SELECT '1' AS success,  'Successful.' as msg;
				return
			END
			ELSE
			BEGIN
				SELECT '0' AS success,  'Something is wrong. Please try again later.' as msg;
				return
			END

		END
		ELSE
		BEGIN
			SELECT '2' AS success,  'Please enter a valid verification code.' as msg;
			return
		END
		
	END
	ELSE
	BEGIN
		SELECT '2' AS success,  'Please request for a verification code.' as msg;
		return
	END
	
END
