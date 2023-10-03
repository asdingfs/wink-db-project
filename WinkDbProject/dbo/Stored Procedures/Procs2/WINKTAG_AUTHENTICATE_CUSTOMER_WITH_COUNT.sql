CREATE PROC [dbo].[WINKTAG_AUTHENTICATE_CUSTOMER_WITH_COUNT]
@campaign_id int,
@customer_id int,
@count int

AS

BEGIN
DECLARE @interval_status int
DECLARE @interval int
DECLARE @limit int
DECLARE @winktag_type varchar(10)
DECLARE	@survey_type varchar(10)

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

	--3)CHECKING WILL BE PROCEEDED BASED ON CAMPAIGN

	--3.0)EASB: CHECK AGE RANGE AND SIZE FOR NIELSEN
	IF (SELECT winktag_report FROM VW_ACTIVE_WINKTAG_CAMPAIGN WHERE campaign_id = @campaign_id) = 'EASB'
	BEGIN
		DECLARE @age int
		--a)CHECK AGE RANGE
		set @age = (select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25) from customer where customer_id =@customer_id)

		IF (@age < 18 OR @age > 35)
		BEGIN
			SELECT '0' AS response_code, 'Open to selected participants' as response_message
			return
		END

		--b)CHECK SIZE
		IF (SELECT COUNT(*) FROM winktag_customer_earned_points WHERE CAMPAIGN_ID = @CAMPAIGN_ID) >= (SELECT SIZE FROM VW_ACTIVE_WINKTAG_CAMPAIGN WHERE campaign_id = @campaign_id)
		BEGIN
			SELECT '0' AS response_code, 'Campaign limit reach' as response_message
			return
		END
	END

	--3.1)SMA2017: CHECK CUSTOMER SCANNED SMA QR CODE OR NOT FOR SMA2017 CAMPAIGN (those who scanned SMA QR code will only be allowed to participate in WINK Tag Survey)
	IF (SELECT winktag_report FROM VW_ACTIVE_WINKTAG_CAMPAIGN WHERE campaign_id = @campaign_id) = 'SMA2017'
	BEGIN

		--a)CHECK CUSTOMER SCANNED SMA QR CODE OR NOT 
		IF NOT EXISTS(SELECT * FROM CUSTOMER_EARNED_POINTS WHERE QR_CODE = 'SMA_SMA_21_49653' AND CUSTOMER_ID = @CUSTOMER_ID)
		BEGIN
			SELECT '0' AS response_code, 'By invitation only' as response_message
			return
		END

	END


	--4)CHECK COUNT
	/*************Nielsen***************/
	/*
	IF (SELECT winktag_report FROM VW_ACTIVE_WINKTAG_CAMPAIGN WHERE campaign_id = @campaign_id) = 'EASB'
	BEGIN

		declare @min_count int = (SELECT min_count FROM VW_ACTIVE_WINKTAG_CAMPAIGN WHERE campaign_id = @campaign_id)
		declare @max_count int = (SELECT max_count FROM VW_ACTIVE_WINKTAG_CAMPAIGN WHERE campaign_id = @campaign_id)

		IF (@count < @min_count) OR (@count > @max_count)
		BEGIN
			SELECT '0' AS response_code, 'Invalid ranking count'  as response_message
			return
		END
	END
	*/
	/*************Nielsen***************/

	/*
	--3)CHECK COUNT --(@count value zero will be passed from backend if it is not required to check the total count for sub questions)
	IF @count > 0 -- need to check the total count for sub questions
	BEGIN
		declare @min_count int = (SELECT min_count FROM VW_ACTIVE_WINKTAG_CAMPAIGN WHERE campaign_id = @campaign_id)
		declare @max_count int = (SELECT max_count FROM VW_ACTIVE_WINKTAG_CAMPAIGN WHERE campaign_id = @campaign_id)

		IF (@count < @min_count) OR (@count > @max_count)
		BEGIN
			SELECT '0' AS response_code, 'Invalid ranking count'  as response_message
			return
		END
	END
	*/

	--5)CHECK LIMIT
	SET @interval_status = (SELECT interval_status FROM VW_ACTIVE_WINKTAG_CAMPAIGN WHERE campaign_id = @campaign_id)

	IF @interval_status = 0 -- there is no interval
	BEGIN
		SET @limit = (SELECT limit FROM VW_ACTIVE_WINKTAG_CAMPAIGN WHERE campaign_id = @campaign_id)
		SET @winktag_type = (SELECT winktag_type FROM VW_ACTIVE_WINKTAG_CAMPAIGN WHERE campaign_id = @campaign_id)

		IF @limit = 0
		BEGIN
			SELECT '1' AS response_code, 'Success' as response_message
			return;
		END
		ELSE
		BEGIN
			IF @winktag_type = 'survey' OR @winktag_type = 'template_survey'
			BEGIN
				SET @survey_type = (SELECT survey_type FROM VW_ACTIVE_WINKTAG_CAMPAIGN WHERE campaign_id = @campaign_id)
				IF @survey_type = 'all'
				BEGIN
					IF (SELECT COUNT(*) FROM winktag_customer_earned_points WHERE customer_id = @customer_id AND campaign_id=@campaign_id) < @limit
					BEGIN
						SELECT '1' AS response_code, 'Success' as response_message
						return;
					END
					ELSE
					BEGIN
						SELECT '0' AS response_code, 'Our records indicate that you have already participated in this survey.' as response_message
						return;
					END
				END
			END
		END
	END
END
		
