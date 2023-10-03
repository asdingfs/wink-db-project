CREATE PROC [dbo].[Convert_Points_To_Winks_By_CampaignId_App003_testing]

@customer_tokenid VARCHAR(255),
@campaign_id int,
@total_redeemed_points int


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

	Set @REDEEMED_POINTS = @total_redeemed_points

	DECLARE @locked_reason varchar(255)
	DECLARE @locked_customer_id int 
	DECLARE @admin_user_email_for_lock_account  varchar(255) 


	SET @admin_user_email_for_lock_account = 'system@winkwink.sg'

	--WINK Expired
	If CAST(@CURRENT_DATETIME as datetime) >= Cast('2021-01-01 00:00:00' as datetime)
	AND CAST(@CURRENT_DATETIME as datetime) <= Cast('2021-01-01 05:30:00' as datetime)
	BEGIN
		SELECT '0' as response_code, 'From 00:00 hrs 01 Jan 2021 to 05:30 hrs 01 Jan 2021, no wink redemption and/or evoucher conversion allowed' as response_message
		RETURN 
	END
	-- END WINK Expired 00:30 and 05:30
	
	-- Check Multiple Login
	
	IF NOT EXISTS (Select 1 From customer where auth_token = @customer_tokenid)
	BEGIN
		SELECT '2' as response_code, 'Multiple logins not allowed' as response_message 
		RETURN
	END
   -- Check for User Profile
	IF Exists (
		Select 1 
		from customer 
		where (ISNULL(customer.phone_no,'') ='' OR ISNULL(customer.gender,'')='' OR ISNULL(customer.date_of_birth,'')='')
		and customer.auth_token =@customer_tokenid
	)
	BEGIN
		SELECT '0' as response_code, 'Please edit and complete your profile or continue to scan and earn points' as response_message
		RETURN
	END
			   
	-- Check Balanced Points and Redeemed Points
	SELECT TOP 1 @CUSTOMER_ID = CUSTOMER_ID FROM CUSTOMER WHERE auth_token = @customer_tokenid;
	SELECT @RATE_VALUE = RATE_VALUE FROM RATE_CONVERSION WHERE RATE_CODE = 'points_per_wink';
    IF (@REDEEMED_POINTS<0 OR @REDEEMED_POINTS =0 OR @REDEEMED_POINTS<@RATE_VALUE)
	BEGIN
		SELECT '0' as response_code, 'You need 50 points to redeem 1 WINK' as response_message
		RETURN
	END

	--limit
	DECLARE @LIMIT_ECO_WINKS INT
	DECLARE @ECO_ID INT

	select @ECO_ID = customer_id, @LIMIT_ECO_WINKS = sum(total_winks)
	from customer_earned_winks  
	where CAST( @CURRENT_DATETIME As Date) = CAST( created_at As Date) 
	and customer_id = @CUSTOMER_ID
	group by customer_id;
 
	print(@LIMIT_ECO_WINKS)

	if(@LIMIT_ECO_WINKS >= 20)
	BEGIN
		SELECT '0' as response_code, 'Daily limit of 20 winks redemption.' as response_message
		RETURN
	END
	IF EXISTS(SELECT * FROM CUSTOMER_BALANCE WHERE CUSTOMER_ID = @CUSTOMER_ID)
	BEGIN
		SELECT @CUSTOMER_BALANCE_POINTS = (TOTAL_POINTS - (USED_POINTS + CONFISCATED_POINTS)) FROM CUSTOMER_BALANCE WHERE CUSTOMER_ID=@CUSTOMER_ID;
		Print ('@CUSTOMER_BALANCE_POINTS')			
		Print (@CUSTOMER_BALANCE_POINTS)			
		IF (@REDEEMED_POINTS>@CUSTOMER_BALANCE_POINTS)
		BEGIN
			SELECT '0' as response_code, 'You do not have enough points' as response_message
			RETURN
		END	
	END	
		
	--- Check Customer WINKs
	SET @WINKS = @REDEEMED_POINTS/@RATE_VALUE;

	IF EXISTS(SELECT * FROM CUSTOMER WHERE auth_token = @customer_tokenid and customer.status ='enable')
	BEGIN 
		SELECT @MERCHANT_TOTAL_WINKS = SUM(TOTAL_WINKS)+ SUM (campaign.total_wink_confiscated) , @merchant_id = campaign.merchant_id 
		FROM CAMPAIGN 
		WHERE campaign.campaign_id =@campaign_id
		AND campaign.campaign_status ='enable'
		AND CONVERT(CHAR(10),@CURRENT_DATETIME,111) >= CONVERT(CHAR(10),CAMPAIGN_START_DATE,111)
		GROUP BY campaign.merchant_id;

		IF EXISTS (SELECT 1 FROM CUSTOMER_EARNED_WINKS WHERE campaign_id = @campaign_id)
		BEGIN
			SELECT @CUSTOMER_TOTAL_EARNED_WINKS_BY_MERCHANT = SUM(TOTAL_WINKS) 
			FROM CUSTOMER_EARNED_WINKS
			WHERE customer_earned_winks.campaign_id = @campaign_id;

			SET @MERCHANT_BALANCE_WINKS = @MERCHANT_TOTAL_WINKS-@CUSTOMER_TOTAL_EARNED_WINKS_BY_MERCHANT;
		END
		ELSE
		BEGIN
			SET @MERCHANT_BALANCE_WINKS = @MERCHANT_TOTAL_WINKS-0;
		END

		IF (@MERCHANT_BALANCE_WINKS = 0)
		BEGIN
			--SELECT '0' as response_code, 'Not enough WINKs to redeem' as response_message
			SELECT '0' as response_code, 'There are no more WINKs left.' as response_message
			RETURN
		END
		ELSE IF(@MERCHANT_BALANCE_WINKS <@WINKS)
		BEGIN
			IF(@MERCHANT_BALANCE_WINKS >1)
			BEGIN
				SELECT '0' as response_code, 'There are only '+ CAST(@MERCHANT_BALANCE_WINKS as varchar(10))+ ' WINKs left. To redeem, please edit your input accordingly.' as response_message
				RETURN
			END
			ELSE
			BEGIN
				SELECT '0' as response_code, 'There are only '+ CAST(@MERCHANT_BALANCE_WINKS as varchar(10))+ ' WINK left. To redeem, please edit your input accordingly.' as response_message
				RETURN
			END
			
		END
		ELSE 
		BEGIN
		    IF EXISTS(SELECT * FROM CUSTOMER_BALANCE WHERE CUSTOMER_ID = @CUSTOMER_ID)
		    BEGIN
				IF (@WINKS IS NOT NULL AND @WINKS !=0 AND @REDEEMED_POINTS !=0 AND @REDEEMED_POINTS IS NOT NULL)
				BEGIN
                    SET @REDEEMED_POINTS = @WINKS*@RATE_VALUE;
                    BEGIN TRANSACTION;  
					BEGIN TRY  

						UPDATE CUSTOMER_BALANCE 
					SET USED_POINTS = USED_POINTS+@REDEEMED_POINTS, TOTAL_WINKS = TOTAL_WINKS+@WINKS 
					WHERE CUSTOMER_ID = @CUSTOMER_ID 
					AND (total_points - (used_points+confiscated_points)) >= @RATE_VALUE 
					AND  (total_points - (used_points+confiscated_points)) >= @REDEEMED_POINTS

					IF(@@ROWCOUNT>0) 
					BEGIN
						IF((@MERCHANT_BALANCE_WINKS - @WINKS) = 0)
						BEGIN
							UPDATE campaign
							SET campaign_status = 'disable'
							WHERE campaign_id = @campaign_id;
						END

						INSERT INTO CUSTOMER_EARNED_WINKS 
						(CUSTOMER_ID,MERCHANT_ID,TOTAL_WINKS,REDEEMED_POINTS,CAMPAIGN_ID,CREATED_AT,UPDATED_AT) 
						VALUES
						(@CUSTOMER_ID,@merchant_id,@WINKS,@REDEEMED_POINTS,@campaign_id,@CURRENT_DATETIME,@CURRENT_DATETIME);

						IF(@@ROWCOUNT>0)
						BEGIN
							COMMIT TRANSACTION
							SELECT @CUSTOMER_USED_WINKS = USED_WINKS ,@CUSTOMER_WINKS_BALANCE = TOTAL_WINKS-USED_WINKS, @CUSTOMER_BALANCE_POINTS = TOTAL_POINTS-USED_POINTS-confiscated_points 
							FROM CUSTOMER_BALANCE 
							WHERE CUSTOMER_ID=@CUSTOMER_ID;

							--SubZero Safeguard 
							If(@CUSTOMER_BALANCE_POINTS < 0)	
							BEGIN
								Update customer set customer.status = 'disable', customer.updated_at = @CURRENT_DATETIME where customer.auth_token = @customer_tokenid;

								IF (@@ROWCOUNT>0)
								BEGIN
									Insert into System_Log (customer_id, action_status,created_at,reason)
									Select customer.customer_id,
									'disable',@CURRENT_DATETIME,'Negative Point Balance'
									from customer where customer.auth_token = @customer_tokenid;
	 
	 								-----INSERT INTO ACCOUNT FILTERING LOCK
			
									Select @locked_customer_id = customer.customer_id 
									from customer where customer.auth_token = @customer_tokenid
									set @locked_reason ='Subzero';
				 
									EXEC Create_WINK_Account_Filtering @locked_customer_id,@locked_reason,@admin_user_email_for_lock_account
									SELECT '0' as response_code, 'Your account is locked. Please contact customer service.' as response_message; 
									RETURN
								END
							END
							--End SubZero Safeguard 

							
							SELECT '1' as response_code, 'Success' as response_message,
							@CUSTOMER_WINKS_BALANCE AS CUSTOMER_WINKS_BALANCE,
							@REDEEMED_POINTS AS REDEEMED_POINTS,
							@WINKS AS WINK_ADDED,
							@CUSTOMER_USED_WINKS as USED_WINKS,
  							@CUSTOMER_BALANCE_POINTS AS CUSTOMER_POINTS_BALANCE;
							RETURN
						END
						ELSE
						BEGIN
							ROLLBACK TRANSACTION 
							SELECT '0' as response_code, 'Insert Failed, Please try again' as response_message 
							RETURN
						END
					END
					ELSE
					BEGIN
						ROLLBACK TRANSACTION 
						SELECT '0' as response_code, 'Update Failed, Please try again' as response_message 
						RETURN;
					END

					END TRY  
					BEGIN CATCH 
						IF @@TRANCOUNT > 0
							ROLLBACK TRANSACTION;  
						SELECT '0' as response_code, 'Transaction Failed, Please try again' as response_message 
					END CATCH;  

				END
				ELSE
				BEGIN
					SELECT '0' as response_code, 'Error in Winks and Redeemed Points' as response_message
					RETURN
				END
		     END
		END
	END
	ELSE
	BEGIN
		SELECT '0' as response_code, 'Invalid Redemption' as response_message
		RETURN
	END
END
