CREATE PROCEDURE [dbo].[Get_Used_eVouchersList_By_TokenId]
	(@customer_token_id varchar(255))
AS
BEGIN
	DECLARE @customerId int
	SET @customerId = (SELECT customer.customer_id  FROM customer WHERE customer.auth_token =@customer_token_id)
	IF (@customerId IS NULL OR @customerId = 0 OR @customerId ='')
		BEGIN
		SELECT '0' AS response_code , 'No Customer ' As response_message
	
		END
	ELSE 
		BEGIN
		SELECT * FROM customer_earned_evouchers where customer_earned_evouchers.used_status=1
		AND customer_earned_evouchers.customer_id =@customerId
		ORDER BY customer_earned_evouchers.earned_evoucher_id DESC
		RETURN
		
		END
	
END
