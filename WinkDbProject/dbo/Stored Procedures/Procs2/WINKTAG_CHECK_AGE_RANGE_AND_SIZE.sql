CREATE PROC [dbo].[WINKTAG_CHECK_AGE_RANGE_AND_SIZE]
@customer_id int,
@campaign_id int

AS

BEGIN

	--0)CUSTOMER ID is null or empty
	IF (@customer_id is null or @customer_id = '')
	BEGIN
		SELECT '0' AS response_code, 'Poor network connection' as response_message
		return
	END

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

	--3)CHECK CUSTOMER PARTICIPATED THE CAMPAIGN
	DECLARE @limit int = (SELECT limit FROM VW_ACTIVE_WINKTAG_CAMPAIGN WHERE campaign_id = @campaign_id)
	IF @limit > 0
	BEGIN
		IF (SELECT COUNT(*) FROM winktag_customer_earned_points WHERE campaign_id = @campaign_id AND customer_id = @customer_id) >= @limit
		BEGIN
			SELECT '0' AS response_code, 'Our records indicate that you have already participated in this survey.' as response_message
			return
		END		
	END

	--4)CHECK PHONE NO is in invitation list for the campaign
	--IF EXISTS (SELECT * FROM winktag_approved_phone_list WHERE CAMPAIGN_ID = @campaign_id)
	--BEGIN
		--DECLARE @phone_no varchar(20) = (SELECT phone_no from customer where customer_id = @customer_id)
		
		--IF NOT EXISTS (SELECT * FROM winktag_approved_phone_list WHERE CAMPAIGN_ID = @campaign_id AND phone_no = @phone_no)
		--BEGIN
		--	SELECT '0' AS response_code, 'Thank you very much for your interest. This survey is by invitation only.' as response_message
		--	return
		--END	 
	--END

	--5)CHECK AGE RANGE AND SIZE FOR NIELSEN
	IF (SELECT winktag_report FROM VW_ACTIVE_WINKTAG_CAMPAIGN WHERE campaign_id = @campaign_id) = 'EASB'
	BEGIN
		DECLARE @age int
		--5.1)CHECK AGE RANGE
		set @age = (select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25) from customer where customer_id =@customer_id)

		IF (@age < 18 OR @age > 35)
		BEGIN
			SELECT '0' AS response_code, 'Open to selected participants' as response_message
			return
		END

		--5.2)CHECK SIZE
		IF (SELECT COUNT(*) FROM winktag_customer_earned_points WHERE CAMPAIGN_ID = @CAMPAIGN_ID) >= (SELECT SIZE FROM VW_ACTIVE_WINKTAG_CAMPAIGN WHERE campaign_id = @campaign_id)
		BEGIN
			SELECT '0' AS response_code, 'Campaign limit reach' as response_message
			return
		END

	END
	

	SELECT '1' AS response_code, 'Success' as response_message
	return;

END
		
