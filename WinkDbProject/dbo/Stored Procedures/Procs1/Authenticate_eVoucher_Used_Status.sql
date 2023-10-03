-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Authenticate_eVoucher_Used_Status]
	(@eVoucher_code varchar(100))
	 
AS
BEGIN

Declare @customer_id int
DECLARE @current_date datetime
EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date output

Select @customer_id = customer_id from customer_earned_evouchers 
where Lower(LTRIM(RTRIM(eVoucher_code)))= Lower(LTRIM(RTRIM(@eVoucher_code)))
AND customer_earned_evouchers.used_status=0 


IF(@customer_id is not null and @customer_id !=0)
BEGIN
  IF Exists (select 1 from customer where customer_id = @customer_id
  and status='disable')
  BEGIN
 	SELECT '0' AS response_code , 'eVoucher code is not valid' as response_message,
		'true' As used_status
	
	Return
	
  END

END



IF (Cast(@current_date as date) = Cast('2017-08-07' as date))

BEGIN

--SELECT '0' AS response_code , 'WINK+ eVoucher code not accepted on 9th Aug 2017.' as response_message 
SELECT '0' AS response_code , 'WINK+ eVoucher code not accepted on 9th Aug 2017.' as response_message,
		'true' As used_status
RETURN

END



IF EXISTS (Select * from customer_earned_evouchers 
where Lower(LTRIM(RTRIM(eVoucher_code)))= Lower(LTRIM(RTRIM(@eVoucher_code)))
AND customer_earned_evouchers.used_status=0)
	BEGIN
	
	SELECT '1' AS response_code ,'Success' as response_message,
	'false' As used_status
	--customer_earned_evouchers.eVoucher_code,
	--eVoucher_amount,
	
	RETURN
	
	END 
	
ELSE

	BEGIN
	
		SELECT '0' AS response_code , 'eVoucher code is not valid' as response_message,
		'true' As used_status
	
	END
	
END
