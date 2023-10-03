CREATE PROCEDURE [dbo].[Get_Used_eVouchersList_By_TokenId_And_Duration]
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
		SELECT '0' AS response_code , 'No Customer ' As response_message
	
		END
	ELSE 
		BEGIN
		-- latest 3 months
		IF (@duration = 3)
		BEGIN
			Select customer_earned_evouchers.earned_evoucher_id , customer_earned_evouchers.redeemed_winks,
			customer_earned_evouchers.eVoucher_amount,customer_earned_evouchers.eVoucher_code,
			eVoucher_transaction.ID,
			eVoucher_transaction.created_at as redeemed_at from 
			customer_earned_evouchers,eVoucher_transaction
			Where customer_earned_evouchers.earned_evoucher_id = eVoucher_transaction.eVoucher_id
			AND customer_earned_evouchers.customer_id =@customerId
			AND customer_earned_evouchers.used_status =1
			AND (cast(eVoucher_transaction.created_at as date) BETWEEN cast(DATEADD(month, -3, GETDATE()) as date) and cast(@CURRENT_DATETIME as date)  )
			ORDER BY eVoucher_transaction.ID DESC;
			RETURN
		END
		-- all
		ELSE IF (@duration =0)
		BEGIN
			Select customer_earned_evouchers.earned_evoucher_id , customer_earned_evouchers.redeemed_winks,
			customer_earned_evouchers.eVoucher_amount,customer_earned_evouchers.eVoucher_code,
			eVoucher_transaction.ID,
			eVoucher_transaction.created_at as redeemed_at from 
			customer_earned_evouchers,eVoucher_transaction
			Where customer_earned_evouchers.earned_evoucher_id = eVoucher_transaction.eVoucher_id
			AND customer_earned_evouchers.customer_id =@customerId
			AND customer_earned_evouchers.used_status =1
			ORDER BY eVoucher_transaction.ID DESC;
			RETURN
		END
		ELSE IF (@duration = 1)
		BEGIN
			Select customer_earned_evouchers.earned_evoucher_id , customer_earned_evouchers.redeemed_winks,
			customer_earned_evouchers.eVoucher_amount,customer_earned_evouchers.eVoucher_code,
			eVoucher_transaction.ID,
			eVoucher_transaction.created_at as redeemed_at from 
			customer_earned_evouchers,eVoucher_transaction
			Where customer_earned_evouchers.earned_evoucher_id = eVoucher_transaction.eVoucher_id
			AND customer_earned_evouchers.customer_id =@customerId
			AND customer_earned_evouchers.used_status =1
			AND CONVERT(VARCHAR(10),eVoucher_transaction.created_at,110) = CONVERT(VARCHAR(10),@CURRENT_DATETIME,110)
			ORDER BY eVoucher_transaction.ID DESC;
			RETURN
		END
		ELSE IF (@duration = 7)
		BEGIN
			Select customer_earned_evouchers.earned_evoucher_id , customer_earned_evouchers.redeemed_winks,
			customer_earned_evouchers.eVoucher_amount,customer_earned_evouchers.eVoucher_code,
			eVoucher_transaction.ID,
			eVoucher_transaction.created_at as redeemed_at from 
			customer_earned_evouchers,eVoucher_transaction
			Where customer_earned_evouchers.earned_evoucher_id = eVoucher_transaction.eVoucher_id
			AND customer_earned_evouchers.customer_id =@customerId
			AND customer_earned_evouchers.used_status =1
			AND CONVERT(VARCHAR(10),eVoucher_transaction.created_at,110) BETWEEN DATEADD(day,-7, CONVERT(VARCHAR(10),@CURRENT_DATETIME,110))AND  DATEADD(day,-1, CONVERT(VARCHAR(10),@CURRENT_DATETIME,110))
			ORDER BY eVoucher_transaction.ID DESC;
			RETURN
		END
		ELSE IF (@duration = 14)
		BEGIN
			Select customer_earned_evouchers.earned_evoucher_id , customer_earned_evouchers.redeemed_winks,
			customer_earned_evouchers.eVoucher_amount,customer_earned_evouchers.eVoucher_code,
			eVoucher_transaction.ID,
			eVoucher_transaction.created_at as redeemed_at from 
			customer_earned_evouchers,eVoucher_transaction
			Where customer_earned_evouchers.earned_evoucher_id = eVoucher_transaction.eVoucher_id
			AND customer_earned_evouchers.customer_id =@customerId
			AND customer_earned_evouchers.used_status =1
			AND CONVERT(VARCHAR(10),eVoucher_transaction.created_at,110) BETWEEN DATEADD(day,-14, CONVERT(VARCHAR(10),@CURRENT_DATETIME,110))AND  DATEADD(day,-1, CONVERT(VARCHAR(10),@CURRENT_DATETIME,110))

			ORDER BY eVoucher_transaction.ID DESC;
		
			RETURN
		END
		ELSE IF (@duration = 30)
		BEGIN
			Select customer_earned_evouchers.earned_evoucher_id , customer_earned_evouchers.redeemed_winks,
			customer_earned_evouchers.eVoucher_amount,customer_earned_evouchers.eVoucher_code,
			eVoucher_transaction.ID,
			eVoucher_transaction.created_at as redeemed_at from 
			customer_earned_evouchers,eVoucher_transaction
			Where customer_earned_evouchers.earned_evoucher_id = eVoucher_transaction.eVoucher_id
			AND customer_earned_evouchers.customer_id =@customerId
			AND customer_earned_evouchers.used_status =1
			AND CONVERT(VARCHAR(10),eVoucher_transaction.created_at,110) BETWEEN DATEADD(day,-30, CONVERT(VARCHAR(10),@CURRENT_DATETIME,110))AND cast(@CURRENT_DATETIME as date)

			ORDER BY eVoucher_transaction.ID DESC;
		END
		
		ELSE IF (@duration = 31)
		BEGIN
			Select Top 31 customer_earned_evouchers.earned_evoucher_id , customer_earned_evouchers.redeemed_winks,
			customer_earned_evouchers.eVoucher_amount,customer_earned_evouchers.eVoucher_code,
			eVoucher_transaction.ID,
			eVoucher_transaction.created_at as redeemed_at from 
			customer_earned_evouchers,eVoucher_transaction
			Where customer_earned_evouchers.earned_evoucher_id = eVoucher_transaction.eVoucher_id
			AND customer_earned_evouchers.customer_id =@customerId
			AND customer_earned_evouchers.used_status =1
			AND CONVERT(VARCHAR(10),eVoucher_transaction.created_at,110) BETWEEN DATEADD(day,-31, CONVERT(VARCHAR(10),@CURRENT_DATETIME,110))AND  DATEADD(day,-1, CONVERT(VARCHAR(10),@CURRENT_DATETIME,110))

			ORDER BY eVoucher_transaction.ID DESC;
			RETURN
		END
		ELSE IF (@duration = 28)
		BEGIN
			Select Top 28 customer_earned_evouchers.earned_evoucher_id , customer_earned_evouchers.redeemed_winks,
			customer_earned_evouchers.eVoucher_amount,customer_earned_evouchers.eVoucher_code,
			eVoucher_transaction.ID,
			eVoucher_transaction.created_at as redeemed_at from 
			customer_earned_evouchers,eVoucher_transaction
			Where customer_earned_evouchers.earned_evoucher_id = eVoucher_transaction.eVoucher_id
			AND customer_earned_evouchers.customer_id =@customerId
			AND customer_earned_evouchers.used_status =1
			AND CONVERT(VARCHAR(10),eVoucher_transaction.created_at,110) BETWEEN DATEADD(day,-28, CONVERT(VARCHAR(10),@CURRENT_DATETIME,110))AND  DATEADD(day,-1, CONVERT(VARCHAR(10),@CURRENT_DATETIME,110))

			ORDER BY eVoucher_transaction.ID DESC;
			RETURN
		END
		
		
	END
	
END
