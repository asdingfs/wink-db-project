CREATE PROCEDURE [dbo].[Get_Avaiable_eVouchersList_By_TokenId]
	(@customer_token_id varchar(255))
AS
BEGIN
	DECLARE @customerId int
	DECLARE @CURRENT_DATETIME DATETIME
	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUT
	SET @customerId = (SELECT customer.customer_id  FROM customer WHERE customer.auth_token =@customer_token_id and customer.status ='enable')
	IF (@customerId IS NULL OR @customerId = 0 OR @customerId ='')
		BEGIN
		select '0' as success , 'Invalid Customer' as response_message
	
		END
	ELSE 
		BEGIN
		select '1' as success,a.customer_id,a.created_at,a.eVoucher_amount,a.eVoucher_code,a.earned_evoucher_id,
		CAST(a.expired_date as Date) as expired_date,
		a.redeemed_date,a.redeemed_winks,a.status from customer_earned_evouchers as a
		where a.used_status=0
		AND a.customer_id =@customerId
		AND CAST(a.expired_date AS DATE) >= CAST (@CURRENT_DATETIME AS Date)
		ORDER BY a.earned_evoucher_id DESC
		RETURN
		
		END
	
END


