CREATE PROCEDURE [dbo].[Auth_Convert_WINKs_To_eVoucher]
	(@redeemed_winks int,
	 @auth_token varchar(100))
AS
BEGIN
DECLARE @customer_id int
DECLARE @current_date datetime
Declare @balanced_winks int
Declare @redeemed_amount decimal(10,2)

EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date output

--WINK Expired
 /*  If CAST(@current_date as datetime) >= Cast('2020-12-29 00:00:00' as datetime)
   AND CAST(@current_date as datetime) <= Cast('2020-12-29 05:30:00' as datetime)
   BEGIN
    
   SELECT '0' as response_code, 'From 00:00 hrs 01 Jan 2021 to 05:30 hrs 01 Jan 2021, no wink redemption and/or evoucher conversion allowed' as response_message
   RETURN 
   END*/
   If CAST(@current_date as datetime) >= Cast('2022-12-12 00:00:00' as datetime)
   AND CAST(@current_date as datetime) <= Cast('2022-12-12 23:59:59' as datetime)
   BEGIN
    
   SELECT '0' as response_code, 'From 00:00 hrs 12 Dec 2022 to 23:59 hrs 12 Dec 2022, no wink redemption and/or evoucher conversion allowed' as response_message
   RETURN 
   END

-- Check account locked
IF EXISTS (select 1 from customer where customer.auth_token = @auth_token and status ='disable')
     BEGIN
   
	 SELECT '3' as response_code, 'Your account is locked. Please contact customer service.' as response_message 
	
		RETURN 
	END-- END

    SELECT @customer_id=customer.customer_id FROM customer WHERE customer.status='enable' and Lower(LTRIM(RTRIM(customer.auth_token))) = Lower(LTRIM(RTRIM(@auth_token)))
	-- Check Customer 
	IF (@customer_id IS NOT NULL AND @customer_id !=0 AND @customer_id !='')
		BEGIN
			IF ((select b.total_winks- (b.confiscated_winks+b.used_winks)  from customer_balance as b where b.customer_id = @customer_id) >=@redeemed_winks)
			BEGIN
			SELECT @redeemed_amount = @redeemed_winks*RATE_VALUE FROM RATE_CONVERSION WHERE RATE_CODE = 'cents_per_wink'
			--- Convert eVoucher Cent To Dollar------------------------
			SET @redeemed_amount = @redeemed_amount/100

			SELECT '1' AS response_code , Concat('You can redeem $',@redeemed_amount,' now or collect more WINKs for redemption later')  as response_message

			END
			Else
			BEGIN

				SELECT '0' AS response_code , 'Insufficient WINKs'  as response_message
			END
		
		END
	ELSE
	
		BEGIN
			--SELECT '0' AS response_code , 'User is not authenticate'  as response_message
			SELECT '0' AS response_code , 'Account is locked or Multiple log in'  as response_message
		END
END
