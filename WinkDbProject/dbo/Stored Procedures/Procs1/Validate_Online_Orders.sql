
CREATE PROC [dbo].[Validate_Online_Orders]
@campaignId int,
@merCusId int,
@orderId int,
@validity varchar(50),
@location varchar(250),
@ipAddress varchar(50)
AS

BEGIN

	DECLARE @CURRENT_DATETIME Datetime ;     
	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUTPUT 
	declare @points as int;
	declare @endTime as datetime;

	--1)CHECK CUSTOMER
	IF NOT EXISTS (SELECT * FROM VW_ACTIVE_CUSTOMER WHERE customer_id = @merCusId)
	BEGIN
		SELECT '0' AS response_code, 'Invalid Customer' as response_message
		return
	END

	--2)CHECK CAMPAIGN
	IF NOT EXISTS (SELECT * FROM VW_ACTIVE_WINKTAG_CAMPAIGN WHERE campaign_id = @campaignId)
	BEGIN
	   SELECT '0' AS response_code, 'This campaign has ended.' as response_message
		return
	END

	SELECT @points = points, @endTime = to_date from winktag_campaign where campaign_id = @campaignId;

	IF(DATEDIFF(minute, CONVERT(DATETIME,@endTime), @CURRENT_DATETIME) >= 4320)
	BEGIN
		SELECT '0' AS response_code, 'This campaign has ended.' as response_message
		return
	END

	--5)CHECK LOCATION		
	IF @location is null or @location = '' or @location = '(null)'
		SET @location = 'User location cannot be detected'

	IF EXISTS(SELECT 1 from wink_delights_online where id = @orderId and completion = 0)
	BEGIN
		
		IF(@validity like 'no')
		BEGIN
			set @points = 0;
		END
		

		UPDATE wink_delights_online
		set mer_id = @merCusId, mer_date = @CURRENT_DATETIME, mer_ip = @ipAddress, mer_location = @location,
		completion = 1, validity = @validity, points = @points
		where id = @orderId;
		 
		IF @@ROWCOUNT > 0
		BEGIN
			If(@campaignId = 145)
			BEGIN
				declare @cusEmail varchar(200);
				declare @cusId int;
				declare @cusName varchar(100);
				declare @orderNo varchar(250);

				SELECT @cusId = cus_id, @orderNo = order_number from wink_delights_online where id = @orderId;
				SELECT @cusEmail = email, @cusName = first_name from customer where customer_id = @cusId;

				IF(@points > 0)
				BEGIN
					

					IF EXISTS (SELECT 1 FROM CUSTOMER_BALANCE WHERE CUSTOMER_ID =@cusId)
					BEGIN
						UPDATE CUSTOMER_BALANCE SET TOTAL_POINTS = (SELECT TOTAL_POINTS FROM CUSTOMER_BALANCE WHERE CUSTOMER_ID =@cusId)+@points 
						,total_scans = (SELECT total_scans FROM CUSTOMER_BALANCE WHERE CUSTOMER_ID =@cusId)+1
						WHERE CUSTOMER_ID =@cusId
						SELECT '1' AS response_code, 'Entry submitted.' as response_message, @cusEmail as cusEmail, @orderNo as orderNo, @cusName as cusName
						return
					END
					ELSE
					BEGIN
						INSERT INTO customer_balance 
						(customer_id,total_points,used_points,total_winks,used_winks,total_evouchers,total_used_evouchers,total_scans)VALUES
						(@cusId,@points,0,0,0,0,0,1) 
						IF(@@ROWCOUNT>0)
						BEGIN
							SELECT '1' AS response_code, 'Entry submitted.' as response_message, @cusEmail as cusEmail, @orderNo as orderNo, @cusName as cusName
							return
						END
						ELSE	
						BEGIN 
							SELECT '0' AS response_code, 'Something''s wrong. Please try again later.' as response_message, '' as cusEmail
							return
						END
					END
				END
				ELSE
				BEGIN
					SELECT '1' AS response_code, 'Entry submitted.' as response_message, @cusEmail as cusEmail, @orderNo as orderNo, @cusName as cusName
					return
				END
				
			END
		
		END
		ELSE
		BEGIN
			SELECT '0' AS response_code, 'Something''s wrong. Please try again later.' as response_message, '' as cusEmail
			return
		END
	END
	ELSE
	BEGIN
		SELECT '0' AS response_code, 'This order has already been validated.' as response_message, '' as cusEmail
		return
	END
	
END

