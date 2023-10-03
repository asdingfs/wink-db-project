CREATE PROC [dbo].[WINKTAG_Authticate_WINKTag_Campaign_By_Campaign_ID]
@customer_id int,
@campaign_id int

AS

BEGIN

    Declare @phone_no varchar(10)
	Declare @age int
	DECLARE @limit int = (SELECT limit FROM VW_ACTIVE_WINKTAG_CAMPAIGN WHERE campaign_id = @campaign_id)
	DECLARE @campaign_type varchar(50)
	


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

	------ Get Customer Info 
	 select  @phone_no = phone_no,@age =floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25) from customer where customer_id= @customer_id and status = 'enable'



	--2)CHECK CAMPAIGN
	IF NOT EXISTS (SELECT * FROM VW_ACTIVE_WINKTAG_CAMPAIGN WHERE campaign_id = @campaign_id)
	BEGIN
	   

		IF NOT EXISTS (select 1 from winktag_approved_phone_list where phone_no = @phone_no and campaign_id =@campaign_id)
		BEGIN
		SELECT '0' AS response_code, 'Invalid Campaign' as response_message
		return
		END	
	   
	END

	SET @campaign_type = (SELECT winktag_report FROM VW_ACTIVE_WINKTAG_CAMPAIGN WHERE campaign_id = @campaign_id)

	--3)CHECK EURO GROUP CAMPAIGN
	IF (@campaign_id =8)
	BEGIN
		--3.0)CHECK CUSTOMER PARTICIPATED THE CAMPAIGN
		IF @limit > 0
		BEGIN
			IF EXISTS(SELECT * FROM winktag_customer_earned_points WHERE campaign_id = @campaign_id AND customer_id = @customer_id AND additional_point_status = 1)
			BEGIN
				SELECT '0' AS response_code, 'Our records indicate that you have already participated in this survey.' as response_message
				return
			END		
		END

		--3.1)ALLOW ONLY FEMALE GENDER
		IF (SELECT gender FROM CUSTOMER WHERE customer_id = @customer_id) <> 'Female'
		BEGIN
			--SELECT '0' AS response_code, 'Only female gender is allowed to participate in this campaign' as response_message
			SELECT '0' AS response_code, 'Open to selected participants' as response_message
			return
		END

		--3.1)ALLOW ONLY AGE
		IF (@age < 18)
		BEGIN
			SELECT '0' AS response_code, 'Open to selected participants' as response_message
			return
		END

		--3.2)
		IF EXISTS (SELECT * FROM winktag_customer_earned_points WHERE campaign_id = @campaign_id AND customer_id = @customer_id and additional_point_status = 0)
		BEGIN
			SELECT '2' AS response_code, 'redirect to third party survey page' as response_message
			return
		END	
		
			
	END

	--3)IF OTHER NORMAL CAMPAIGNS
	ELSE
	BEGIN
		--3.0)CHECK CUSTOMER PARTICIPATED THE CAMPAIGN
		IF @limit > 0
		BEGIN
			IF (SELECT COUNT(*) FROM winktag_customer_earned_points WHERE campaign_id = @campaign_id AND customer_id = @customer_id) >= @limit
			BEGIN

				IF @campaign_type = 'airshow2018'
					SELECT '0' AS response_code, 'You have already participated in this promotion.' as response_message
				ELSE	
					SELECT '0' AS response_code, 'Our records indicate that you have already participated in this survey.' as response_message
				return
			END		
		END
	END
	
	IF (@campaign_id =38 or @campaign_id = 40)
	BEGIN
			IF EXISTS(SELECT * FROM winktag_customer_survey_answer_detail WHERE campaign_id = @campaign_id AND customer_id = @customer_id )
			BEGIN
				SELECT '0' AS response_code, 'Thank you! You have already participated in the WINK+ Mid-Autumn Treats Giveaway.' as response_message
				return
			END		
	END

	else
	BEGIN
	SELECT '1' AS response_code, 'Success' as response_message
	return
	END
	

END
		
