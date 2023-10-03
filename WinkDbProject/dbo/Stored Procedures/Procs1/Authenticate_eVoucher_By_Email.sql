CREATE PROCEDURE [dbo].[Authenticate_eVoucher_By_Email]
	(@eVoucher_code varchar(100),
	 @email varchar(100))
AS
BEGIN
DECLARE @customer_id int
DECLARE @current_date datetime

EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date output

IF (Cast(@current_date as date) = Cast('2017-08-07' as date))

BEGIN

SELECT '0' AS response_code , 'WINK+ eVoucher code not accepted on 9th Aug 2017.' as response_message 
RETURN

END

    SELECT @customer_id=customer.customer_id FROM customer WHERE customer.status='enable' and Lower(LTRIM(RTRIM(customer.email))) = Lower(LTRIM(RTRIM(@email)))
	-- Check Customer 
	IF (@customer_id IS NOT NULL AND @customer_id !=0 AND @customer_id !='')
		BEGIN
			IF EXISTS (SELECT customer_earned_evouchers.eVoucher_code FROM customer_earned_evouchers WHERE 
			Lower(LTRIM(RTRIM(eVoucher_code)))= Lower(LTRIM(RTRIM(@eVoucher_code)))
			AND customer_earned_evouchers.customer_id = @customer_id
			and CAST(customer_earned_evouchers.expired_date as Date) > CAST(@current_date as Date) 
			)
				BEGIN
				
				SELECT '1' AS response_code ,'Success' as response_message,
				customer_earned_evouchers.eVoucher_code,
				eVoucher_amount,
				DATEADD(day,-1, CAST(expired_date as Date))as expired_date,
				used_status
				from customer_earned_evouchers 
				WHERE 
			    Lower(LTRIM(RTRIM(eVoucher_code)))= Lower(LTRIM(RTRIM(@eVoucher_code)))
				RETURN 
				
				
				END
				ELSE 
				BEGIN
					SELECT '0' AS response_code , 'eVoucher code is not valid' as response_message
				END
		
		END
	ELSE
	
		BEGIN
			--SELECT '0' AS response_code , 'User is not authenticate'  as response_message
			SELECT '0' AS response_code , 'Invalid eVoucher code'  as response_message
		END
END
