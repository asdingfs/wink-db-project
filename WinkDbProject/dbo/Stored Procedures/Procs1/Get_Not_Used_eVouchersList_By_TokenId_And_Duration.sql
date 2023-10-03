CREATE PROCEDURE [dbo].[Get_Not_Used_eVouchersList_By_TokenId_And_Duration]
	(@customer_token_id varchar(255),
	 @duration int )
AS
BEGIN
	DECLARE @customerId int
	DECLARE @CURRENT_DATETIME DATETIME
	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUT
	SET @customerId = (SELECT customer.customer_id  FROM customer WHERE customer.auth_token =@customer_token_id)
	IF (@customerId IS NULL OR @customerId = 0 OR @customerId ='')
		BEGIN
		SELECT '0' AS response_code , 'User is not authenticate! ' As response_message
	
		END
	ELSE 
		BEGIN
		IF (@duration = 1)
		BEGIN
		
		SELECT  * FROM customer_earned_evouchers where customer_earned_evouchers.used_status=0
		AND customer_earned_evouchers.customer_id =@customerId
		AND CAST(customer_earned_evouchers.expired_date AS DATE) >= CAST (@CURRENT_DATETIME AS Date)
		AND CONVERT(VARCHAR(10),customer_earned_evouchers.created_at,110) = CONVERT(VARCHAR(10),@CURRENT_DATETIME,110)
		ORDER BY customer_earned_evouchers.earned_evoucher_id DESC
		RETURN
		END
		ELSE IF (@duration = 7)
		BEGIN
		
		SELECT  * FROM customer_earned_evouchers where customer_earned_evouchers.used_status=0
		AND customer_earned_evouchers.customer_id =@customerId
		AND CAST(customer_earned_evouchers.expired_date AS DATE) >= CAST (@CURRENT_DATETIME AS Date)
		AND CONVERT(VARCHAR(10),customer_earned_evouchers.created_at,110) BETWEEN DATEADD(day,-7, CONVERT(VARCHAR(10),@CURRENT_DATETIME,110))AND  DATEADD(day,-1, CONVERT(VARCHAR(10),@CURRENT_DATETIME,110))
	
		ORDER BY customer_earned_evouchers.earned_evoucher_id DESC
		RETURN
		END
		ELSE IF (@duration = 14)
		BEGIN
		SELECT  * FROM customer_earned_evouchers where customer_earned_evouchers.used_status=0
		AND customer_earned_evouchers.customer_id =@customerId
		AND CAST(customer_earned_evouchers.expired_date AS DATE) >= CAST (@CURRENT_DATETIME AS Date)
		AND CONVERT(VARCHAR(10),customer_earned_evouchers.created_at,110) BETWEEN DATEADD(day,-14, CONVERT(VARCHAR(10),@CURRENT_DATETIME,110))AND  DATEADD(day,-1, CONVERT(VARCHAR(10),@CURRENT_DATETIME,110))
	
		ORDER BY customer_earned_evouchers.earned_evoucher_id DESC
		RETURN
		END
		
		
		ELSE IF (@duration = 30)
		BEGIN
		SELECT  * FROM customer_earned_evouchers where customer_earned_evouchers.used_status=0
		AND customer_earned_evouchers.customer_id =@customerId
		AND CAST(customer_earned_evouchers.expired_date AS DATE) >= CAST (@CURRENT_DATETIME AS Date)
		AND CONVERT(VARCHAR(10),customer_earned_evouchers.created_at,110) BETWEEN DATEADD(day,-30, CONVERT(VARCHAR(10),@CURRENT_DATETIME,110))AND  DATEADD(day,-1, CONVERT(VARCHAR(10),@CURRENT_DATETIME,110))
	
		ORDER BY customer_earned_evouchers.earned_evoucher_id DESC
		RETURN
		END
		
		ELSE IF (@duration = 31)
		BEGIN
		SELECT  * FROM customer_earned_evouchers where customer_earned_evouchers.used_status=0
		AND customer_earned_evouchers.customer_id =@customerId
		AND CAST(customer_earned_evouchers.expired_date AS DATE) >= CAST (@CURRENT_DATETIME AS Date)
		AND CONVERT(VARCHAR(10),customer_earned_evouchers.created_at,110) BETWEEN DATEADD(day,-31, CONVERT(VARCHAR(10),@CURRENT_DATETIME,110))AND  DATEADD(day,-1, CONVERT(VARCHAR(10),@CURRENT_DATETIME,110))
	
		ORDER BY customer_earned_evouchers.earned_evoucher_id DESC
		RETURN
		END
		
		
		ELSE IF (@duration = 28)
		BEGIN
		SELECT  * FROM customer_earned_evouchers where customer_earned_evouchers.used_status=0
		AND customer_earned_evouchers.customer_id =@customerId
		AND CAST(customer_earned_evouchers.expired_date AS DATE) >= CAST (@CURRENT_DATETIME AS Date)
		AND CONVERT(VARCHAR(10),customer_earned_evouchers.created_at,110) BETWEEN DATEADD(day,-28, CONVERT(VARCHAR(10),@CURRENT_DATETIME,110))AND  DATEADD(day,-1, CONVERT(VARCHAR(10),@CURRENT_DATETIME,110))
	
		ORDER BY customer_earned_evouchers.earned_evoucher_id DESC
		RETURN
		END
		
		ELSE IF (@duration =0)
		BEGIN
		SELECT * FROM customer_earned_evouchers where customer_earned_evouchers.used_status=0
		AND CAST(customer_earned_evouchers.expired_date AS DATE) >= CAST (@CURRENT_DATETIME AS Date)
		AND customer_earned_evouchers.customer_id =@customerId
		RETURN
		END
		
		END
	
END
