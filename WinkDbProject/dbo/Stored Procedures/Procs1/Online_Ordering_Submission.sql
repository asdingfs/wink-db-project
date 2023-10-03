
CREATE PROC [dbo].[Online_Ordering_Submission]
@campaign_id int,
@customer_id int,
@order_num varchar(250),
@location varchar(250),
@ip_address varchar(50)
AS

BEGIN

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
	   SELECT '0' AS response_code, 'This campaign has ended.' as response_message
		return
	END

	IF(@CURRENT_DATETIME > (select to_date from winktag_campaign where campaign_id = @campaign_id))
	BEGIN
		SELECT '0' AS response_code, 'This campaign has ended.' as response_message
		return
	END

	--5)CHECK LOCATION		
	IF @location is null or @location = '' or @location = '(null)'
		SET @location = 'User location cannot be detected'

	IF NOT EXISTS(SELECT order_number from wink_delights_online where order_number like @order_num)
	BEGIN
		INSERT INTO [dbo].[wink_delights_online]
			   ([campaign_id]
			   ,[order_number]
			   ,[cus_id]
			   ,[cus_date]
			   ,[cus_ip]
			   ,[cus_location]
			   ,[completion]
			   ,[validity]
			   ,[points])
		 VALUES
			   (@campaign_id
			   ,@order_num
			   ,@customer_id
			   ,@CURRENT_DATETIME
			   ,@ip_address
			   ,@location
			   ,0
			   ,'No'
			   ,0);
		 
		IF @@ROWCOUNT > 0
		BEGIN
			If(@campaign_id = 145)
			BEGIN

				SELECT '1' AS response_code, 'Your entry has been submitted. You will be rewarded with 200 WINK+ points upon merchant validation.' as response_message
				return

			END
		
		END
		ELSE
		BEGIN
			SELECT '0' AS response_code, 'Something''s wrong. Please try again later.' as response_message
			return
		END
	END
	ELSE
	BEGIN
		SELECT '0' AS response_code, 'Duplicate entry' as response_message
		return
	END
	
END

