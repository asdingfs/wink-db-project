CREATE PROCEDURE [dbo].[Get_Used_eVouchersList_By_StaffTokenId_And_Duration]
	(@staff_token_id varchar(255),
	 @duration int )
AS
BEGIN
	DECLARE @branchId int
	--SET @duration =1
	if(@duration = 0)
	BEGIN
		SET @duration =1;
	END
	DECLARE @CURRENT_DATETIME DATETIME
	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUT
	SET @branchId = ISNULL((SELECT branch.branch_code FROM branch WHERE
	branch.branch_id = (select staff.branch_id from staff where staff.auth_token = @staff_token_id)),0)
	
	
	IF (@branchId IS NULL OR @branchId = 0 OR @branchId ='')
		BEGIN
		SELECT '0' AS response_code , 'Invalid Branch ID ' As response_message
	
		END
	ELSE 
		BEGIN
		-- EXTRACT TODAY
		IF (@duration = 1)
		BEGIN
				
		Select customer_earned_evouchers.earned_evoucher_id , customer_earned_evouchers.redeemed_winks,
	    customer_earned_evouchers.eVoucher_amount,customer_earned_evouchers.eVoucher_code,
	    --eVoucher_transaction.ID,
		@branchId as ID,
		b.branch_name,
		eVoucher_transaction.created_at as redeemed_at from 
		customer_earned_evouchers,eVoucher_transaction,
		branch as b
		Where customer_earned_evouchers.earned_evoucher_id = eVoucher_transaction.eVoucher_id
		and b.branch_code = @branchId
		AND customer_earned_evouchers.used_status =1
		AND eVoucher_transaction.branch_code =@branchId
		
		AND CONVERT(VARCHAR(10),eVoucher_transaction.created_at,110) = CONVERT(VARCHAR(10),@CURRENT_DATETIME,110)
		ORDER BY eVoucher_transaction.ID DESC
		RETURN
		END
		/*ELSE IF (@duration = 7)
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
		ORDER BY eVoucher_transaction.ID DESC
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

		ORDER BY eVoucher_transaction.ID DESC
		
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
		AND CONVERT(VARCHAR(10),eVoucher_transaction.created_at,110) BETWEEN DATEADD(day,-30, CONVERT(VARCHAR(10),@CURRENT_DATETIME,110))AND  DATEADD(day,-1, CONVERT(VARCHAR(10),@CURRENT_DATETIME,110))

		ORDER BY eVoucher_transaction.ID DESC
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

		ORDER BY eVoucher_transaction.ID DESC
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

		ORDER BY eVoucher_transaction.ID DESC
		RETURN
		END
		
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
		ORDER BY eVoucher_transaction.ID DESC
		RETURN
		END
		*/
		END
	
END
