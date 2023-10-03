CREATE PROC [dbo].[Convert_Points_To_Winks_By_CampaignId_App002]

@customer_tokenid VARCHAR(255),
@campaign_id int

AS

DECLARE @CUSTOMER_ID INT

DECLARE @MERCHANT_TOTAL_WINKS INT

DECLARE @CUSTOMER_TOTAL_EARNED_WINKS_BY_MERCHANT INT

DECLARE @MERCHANT_BALANCE_WINKS INT

DECLARE @CUSTOMER_BALANCE_WINKS INT

DECLARE @CUSTOMER_BALANCE_POINTS INT

DECLARE @WINKS INT

DECLARE @CUSTOMER_WINKS INT

DECLARE @REDEEMED_POINTS INT

DECLARE @CUSTOMER_WINKS_BALANCE INT

DECLARE @CUSTOMER_USED_WINKS INT

DECLARE @RATE_VALUE INT

DECLARE @merchant_id int

BEGIN

DECLARE @CURRENT_DATETIME DATETIME



EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUT

     --WINK Expired
   --If CAST(@CURRENT_DATETIME as time) >= '00:00:00' 
   --AND CAST(@CURRENT_DATETIME as time) <= '06:30:00'
   --BEGIN
    
   --SELECT '0' as response_code, 'From 00:00 hrs 01 Jan 2017 to 06:30 hrs 01 Jan 2017,no wink redemption and/or evoucher conversion allowed ' as response_message
   --RETURN 
	--END
	-- END WINK Expired 00:30 and 05:30
	

    IF NOT EXISTS (Select 1 From customer where auth_token = @customer_tokenid)

    BEGIN

		SELECT '2' as response_code, 'Multiple logins not allowed' as response_message 

		RETURN

    END

	

	IF EXISTS(SELECT * FROM CUSTOMER WHERE auth_token = @customer_tokenid and customer.status ='enable')                            

	BEGIN 

		SELECT TOP 1 @CUSTOMER_ID = CUSTOMER_ID FROM CUSTOMER WHERE auth_token = @customer_tokenid 

		SELECT @MERCHANT_TOTAL_WINKS = SUM(TOTAL_WINKS)+ SUM (campaign.total_wink_confiscated) , @merchant_id = campaign.merchant_id FROM CAMPAIGN 

		WHERE 

	    campaign.campaign_id =@campaign_id

		AND campaign.campaign_status ='enable'

		-- update on 29/032016

		AND CONVERT(CHAR(10),@CURRENT_DATETIME,111) >= CONVERT(CHAR(10),CAMPAIGN_START_DATE,111)

		

		/*AND (

		(

		CONVERT(CHAR(10),@CURRENT_DATETIME,111) >= CONVERT(CHAR(10),CAMPAIGN_START_DATE,111) AND

		CONVERT(CHAR(10),@CURRENT_DATETIME,111) <= CONVERT(CHAR(10),campaign.campaign_end_date,111)AND

		campaign.wink_purchase_only=0 -- Add New Changes

		)

		OR 

		(

		Lower(campaign.wink_purchase_status) ='activate'

		AND campaign.wink_purchase_only=1 -- Add New Changes

		)

		

		)*/

		GROUP BY campaign.merchant_id

		

		--print(@MERCHANT_TOTAL_WINKS)

		

		IF EXISTS (SELECT * FROM CUSTOMER_EARNED_WINKS WHERE campaign_id = @campaign_id)

		BEGIN

		

			SELECT @CUSTOMER_TOTAL_EARNED_WINKS_BY_MERCHANT = 

			SUM(TOTAL_WINKS) FROM CUSTOMER_EARNED_WINKS 

			WHERE 

		    customer_earned_winks.campaign_id = @campaign_id

			SET @MERCHANT_BALANCE_WINKS = @MERCHANT_TOTAL_WINKS-@CUSTOMER_TOTAL_EARNED_WINKS_BY_MERCHANT

			--print('@CUSTOMER_TOTAL_EARNED_WINKS_BY_MERCHANT')

			--print(@CUSTOMER_TOTAL_EARNED_WINKS_BY_MERCHANT)

		END

		ELSE

		BEGIN

			SET @MERCHANT_BALANCE_WINKS = @MERCHANT_TOTAL_WINKS-0

		END

		IF @MERCHANT_BALANCE_WINKS = 0

			BEGIN

				SELECT '0' as response_code, 'Not enough WINKs to redeem' as response_message 

				RETURN

			END

		ELSE 

			BEGIN

		IF EXISTS(SELECT * FROM CUSTOMER_BALANCE WHERE CUSTOMER_ID = @CUSTOMER_ID)

		BEGIN

		

			SELECT @CUSTOMER_BALANCE_POINTS = (TOTAL_POINTS - (USED_POINTS + CONFISCATED_POINTS)) FROM CUSTOMER_BALANCE WHERE CUSTOMER_ID=@CUSTOMER_ID

			

			SELECT @RATE_VALUE = RATE_VALUE FROM RATE_CONVERSION WHERE RATE_CODE = 'points_per_wink'

			

			--print ('@@CUSTOMER_BALANCE_POINTS')

			

			--print (@CUSTOMER_BALANCE_POINTS)

			

			IF @CUSTOMER_BALANCE_POINTS = 0 OR  @CUSTOMER_BALANCE_POINTS< @RATE_VALUE

			BEGIN

				SELECT '0' as response_code, 'You need 50 points to redeem 1 WINK' as response_message 

				RETURN

			END

			ELSE

			BEGIN

			

			   -- Check for User Profile

			   IF Exists (Select 1 from customer where (ISNULL(customer.phone_no,'') =''

			   OR ISNULL(customer.gender,'')='' OR ISNULL(customer.date_of_birth,'')='')

			   and customer.auth_token =@customer_tokenid)

			   BEGIN

			   

			   SELECT '0' as response_code, 'Please edit and complete your profile or continue to scan and earn points' as response_message 

			   RETURN

			   END

			   

				SET @CUSTOMER_WINKS = @CUSTOMER_BALANCE_POINTS/@RATE_VALUE

				--SELECT @CUSTOMER_WINKS = @CUSTOMER_BALANCE_POINTS/RATE_VALUE FROM RATE_CONVERSION WHERE RATE_CODE = 'points_per_wink'

				

				--print ('@CUSTOMER_WINKS')

				--print (@CUSTOMER_WINKS)

				

				--print ('@@MERCHANT_BALANCE_WINKS')

				--print (@MERCHANT_BALANCE_WINKS)

				

				IF @CUSTOMER_WINKS <= @MERCHANT_BALANCE_WINKS

				    BEGIN 

					SET @WINKS = @CUSTOMER_WINKS

					END

				ELSE

				    BEGIN

					SET @WINKS = @MERCHANT_BALANCE_WINKS

					END

				

				

				SELECT @REDEEMED_POINTS = @WINKS*RATE_VALUE FROM RATE_CONVERSION WHERE RATE_CODE = 'points_per_wink'

				

				IF (@WINKS IS NOT NULL AND @WINKS !=0 AND @REDEEMED_POINTS !=0 AND @REDEEMED_POINTS IS NOT NULL)

				BEGIN

					UPDATE CUSTOMER_BALANCE SET USED_POINTS = USED_POINTS+@REDEEMED_POINTS, TOTAL_WINKS = TOTAL_WINKS+@WINKS WHERE CUSTOMER_ID = @CUSTOMER_ID 
					AND (total_points - (used_points+confiscated_points)) >= @RATE_VALUE AND  (total_points - (used_points+confiscated_points)) >= @REDEEMED_POINTS

					IF(@@ROWCOUNT>0)
					BEGIN
						INSERT INTO CUSTOMER_EARNED_WINKS 

						(CUSTOMER_ID,MERCHANT_ID,TOTAL_WINKS,REDEEMED_POINTS,CAMPAIGN_ID,CREATED_AT,UPDATED_AT) VALUES

						(@CUSTOMER_ID,@merchant_id,@WINKS,@REDEEMED_POINTS,@campaign_id,@CURRENT_DATETIME,@CURRENT_DATETIME)

						IF(@@ROWCOUNT>0)

						BEGIN

							SELECT @CUSTOMER_USED_WINKS = USED_WINKS ,@CUSTOMER_WINKS_BALANCE = TOTAL_WINKS-USED_WINKS, @CUSTOMER_BALANCE_POINTS = TOTAL_POINTS-USED_POINTS FROM CUSTOMER_BALANCE WHERE CUSTOMER_ID=@CUSTOMER_ID

							SELECT '1' as response_code, 'Success' as response_message,

							 @CUSTOMER_WINKS_BALANCE AS CUSTOMER_WINKS_BALANCE,

							 @REDEEMED_POINTS AS REDEEMED_POINTS,

							 @WINKS AS WINK_ADDED,

							 @CUSTOMER_USED_WINKS as USED_WINKS,

  							 @CUSTOMER_BALANCE_POINTS AS CUSTOMER_POINTS_BALANCE

							RETURN

						END

						ELSE

						BEGIN
							SELECT '0' as response_code, 'Insert Fails' as response_message 
							RETURN
						END
					END
					ELSE
					BEGIN
						SELECT '0' as response_code, 'Update Fails' as response_message 
						RETURN;
					END

				END

				ELSE
				BEGIN

					SELECT '0' as response_code, 'Error in Winks and Redeemed Points' as response_message 

				END
			END

			

		END

		ELSE

		BEGIN

			SELECT '0' as response_code, 'You need 50 points to redeem 1 WINK' as response_message 

			RETURN

		END

		END

	END

	ELSE

	BEGIN

		--SELECT '0' as response_code, 'Customer does not exist' as response_message 

		SELECT '0' as response_code, 'Invalid Redemption' as response_message 

		RETURN

	END

	

END





 

 

 

 

 
