CREATE PROCEDURE [dbo].[Authenticate_eVoucher_Used]
	(@eVoucher_code varchar(100))
	 
AS
BEGIN

IF EXISTS (Select * from customer_earned_evouchers 
where Lower(LTRIM(RTRIM(eVoucher_code)))= Lower(LTRIM(RTRIM(@eVoucher_code))))
	BEGIN
	SELECT '1' AS response_code ,'Success' as response_message,
				customer_earned_evouchers.eVoucher_code,
				eVoucher_amount,
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
