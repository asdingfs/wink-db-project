


CREATE PROCEDURE [dbo].[Get_Customer_eVouchers_Report_with_expired_date]
	(@start_date varchar(50),
	 @end_date varchar(50),
	@customer_name varchar(50),
	@merchant_name varchar(50),
	@used_status varchar(50),
	@expired_status varchar(50)
	)
AS
BEGIN
/*SELECT customer_earned_evouchers.customer_id,customer_earned_evouchers.eVoucher_code,
customer_earned_evouchers.redeemed_winks,customer_earned_evouchers.created_at,customer_earned_evouchers.redeemed_date,

eVoucher_verification.verification_code,
eVoucher_verification.branch_id,branch.branch_name,
merchant.first_name as m_first_name , merchant.last_name as m_last_name,
merchant.merchant_id
from customer_earned_evouchers,eVoucher_verification,branch,merchant
WHERE 
customer_earned_evouchers.earned_evoucher_id = eVoucher_verification.eVoucher_id
AND eVoucher_verification.branch_id = branch.branch_code
AND branch.merchant_id = merchant.merchant_id
AND customer_earned_evouchers.customer_id =@customer_id*/
Declare @used_status_ bit
IF (@used_status!='')
	Begin
	
	IF(Lower(LTRIM(RTRIM(@used_status)))='yes')
	begin
	SET @used_status_ = 1
	end
	else 
	begin
	SET @used_status_ = 0
	end
	END
	
	

IF OBJECT_ID('tempdb..#Customer_eVoucherReport_Table') IS NOT NULL DROP TABLE #Customer_eVoucherReport_Table

	CREATE TABLE #Customer_eVoucherReport_Table
	(
	 evoucher_id int,
	 customer_id int,
	 eVoucher_code varchar(200),
	 eVoucher_amount decimal(10,2),
	 c_first_name varchar(100),
	 c_last_name varchar(100),
	 redeemed_winks int,
	 created_at DateTime,
	 updated_at DateTime,
	 used_status Bit,
	 expired_date DateTime,
	 branch_code varchar(100) ,
	 redeemed_on DateTime,
	 verification_code varchar(100),
	 merchant_id int,
	 transaction_id int,
	 m_first_name varchar(100),
	 m_last_name varchar(100),
	 branch_name varchar(100),
	 order_no varchar(50)
 
	)


/*--- Check By Date ----------------*/



IF (@start_date IS NOT NULL AND @end_date IS NOT NULL AND @start_date!='' AND @end_date !='')
BEGIN
		
		--if expired status is null
		IF(Lower(LTRIM(RTRIM(@expired_status)))='')
		BEGIN
		
			INSERT INTO #Customer_eVoucherReport_Table (
			 evoucher_id,
			 customer_id ,
			 eVoucher_code ,
			 eVoucher_amount ,
			 c_first_name ,
			 c_last_name,
			 redeemed_winks ,
			 created_at ,
			 updated_at ,
			 used_status ,
			 expired_date ,
			 branch_code,
			 redeemed_on ,
			 verification_code ,
			 merchant_id ,
			 transaction_id ,
			 m_first_name ,
			 m_last_name ,
			 branch_name,
			 order_no
			 )

			SELECT customer_earned_evouchers.earned_evoucher_id,customer_earned_evouchers.customer_id,customer_earned_evouchers.eVoucher_code,
			customer_earned_evouchers.eVoucher_amount,
			customer.first_name as c_first_name,customer.last_name as c_last_name,
			customer_earned_evouchers.redeemed_winks,
			customer_earned_evouchers.created_at,customer_earned_evouchers.updated_at,

			customer_earned_evouchers.used_status,customer_earned_evouchers.expired_date,
			eVoucher_transaction.branch_code,eVoucher_transaction.created_at as redeemed_on,
			(SELECT Top 1 eVoucher_verification .verification_code from eVoucher_verification
			 where eVoucher_verification.eVoucher_id = customer_earned_evouchers .earned_evoucher_id
			 Order by eVoucher_verification.created_at DESC) AS verification_code,merchant.merchant_id,
			 eVoucher_transaction.transaction_id,
			  merchant.first_name as m_first_name , merchant.last_name as m_last_name,
			 branch.branch_name,eVoucher_transaction.order_no
			from customer_earned_evouchers JOIN customer ON
			customer_earned_evouchers.customer_id = customer.customer_id
			LEFT JOIN eVoucher_transaction ON eVoucher_transaction.eVoucher_id = customer_earned_evouchers.earned_evoucher_id
			LEFT JOIN merchant ON merchant.merchant_id = eVoucher_transaction.merchant_id
			LEFT JOIN branch ON eVoucher_transaction.branch_code = branch.branch_code
			WHERE  CAST(customer_earned_evouchers.created_at as Date)>= CAST(@start_date  as DATE)
				 AND CAST(customer_earned_evouchers.created_at as DATE) <= CAST(@end_date as DATE)

				/* AND Lower(customer.first_name + ' ' + customer.last_name) LIKE Lower('%'+ @customer_name +'%') 
				 AND Lower(merchant.first_name + ' ' + merchant.last_name) LIKE Lower('%'+ @merchant_name +'%')
				 AND Lower(customer_earned_evouchers.used_status) LIKE Lower('%'+ @used_status +'%')*/

			--order by eVoucher_transaction.eVoucher_id desc
			order by customer_earned_evouchers.updated_at desc
		
		END
		
		--if expired status is yes
		IF(Lower(LTRIM(RTRIM(@expired_status)))='yes')
		BEGIN
		
			INSERT INTO #Customer_eVoucherReport_Table (
			 evoucher_id,
			 customer_id ,
			 eVoucher_code ,
			 eVoucher_amount ,
			 c_first_name ,
			 c_last_name,
			 redeemed_winks ,
			 created_at ,
			 updated_at ,
			 used_status ,
			 expired_date ,
			 branch_code,
			 redeemed_on ,
			 verification_code ,
			 merchant_id ,
			 transaction_id ,
			 m_first_name ,
			 m_last_name ,
			 branch_name,
			 order_no
			 )

			SELECT customer_earned_evouchers.earned_evoucher_id,customer_earned_evouchers.customer_id,customer_earned_evouchers.eVoucher_code,
			customer_earned_evouchers.eVoucher_amount,
			customer.first_name as c_first_name,customer.last_name as c_last_name,
			customer_earned_evouchers.redeemed_winks,
			customer_earned_evouchers.created_at,customer_earned_evouchers.updated_at,

			customer_earned_evouchers.used_status,customer_earned_evouchers.expired_date,
			eVoucher_transaction.branch_code,eVoucher_transaction.created_at as redeemed_on,
			(SELECT Top 1 eVoucher_verification .verification_code from eVoucher_verification
			 where eVoucher_verification.eVoucher_id = customer_earned_evouchers .earned_evoucher_id
			 Order by eVoucher_verification.created_at DESC) AS verification_code,merchant.merchant_id,
			 eVoucher_transaction.transaction_id,
			  merchant.first_name as m_first_name , merchant.last_name as m_last_name,
			 branch.branch_name,eVoucher_transaction.order_no
			from customer_earned_evouchers JOIN customer ON
			customer_earned_evouchers.customer_id = customer.customer_id
			LEFT JOIN eVoucher_transaction ON eVoucher_transaction.eVoucher_id = customer_earned_evouchers.earned_evoucher_id
			LEFT JOIN merchant ON merchant.merchant_id = eVoucher_transaction.merchant_id
			LEFT JOIN branch ON eVoucher_transaction.branch_code = branch.branch_code
			WHERE  CAST(customer_earned_evouchers.created_at as Date)>= CAST(@start_date  as DATE)
				 AND CAST(customer_earned_evouchers.created_at as DATE) <= CAST(@end_date as DATE)
				 AND customer_earned_evouchers.expired_date < GETDATE()

				/* AND Lower(customer.first_name + ' ' + customer.last_name) LIKE Lower('%'+ @customer_name +'%') 
				 AND Lower(merchant.first_name + ' ' + merchant.last_name) LIKE Lower('%'+ @merchant_name +'%')
				 AND Lower(customer_earned_evouchers.used_status) LIKE Lower('%'+ @used_status +'%')*/

			--order by eVoucher_transaction.eVoucher_id desc
			order by customer_earned_evouchers.updated_at desc
		
		END
		
		--if expired status is no
		IF(Lower(LTRIM(RTRIM(@expired_status)))='no')
		BEGIN
		
			INSERT INTO #Customer_eVoucherReport_Table (
			 evoucher_id,
			 customer_id ,
			 eVoucher_code ,
			 eVoucher_amount ,
			 c_first_name ,
			 c_last_name,
			 redeemed_winks ,
			 created_at ,
			 updated_at ,
			 used_status ,
			 expired_date ,
			 branch_code,
			 redeemed_on ,
			 verification_code ,
			 merchant_id ,
			 transaction_id ,
			 m_first_name ,
			 m_last_name ,
			 branch_name,
			 order_no
			 )

			SELECT customer_earned_evouchers.earned_evoucher_id,customer_earned_evouchers.customer_id,customer_earned_evouchers.eVoucher_code,
			customer_earned_evouchers.eVoucher_amount,
			customer.first_name as c_first_name,customer.last_name as c_last_name,
			customer_earned_evouchers.redeemed_winks,
			customer_earned_evouchers.created_at,customer_earned_evouchers.updated_at,

			customer_earned_evouchers.used_status,customer_earned_evouchers.expired_date,
			eVoucher_transaction.branch_code,eVoucher_transaction.created_at as redeemed_on,
			(SELECT Top 1 eVoucher_verification .verification_code from eVoucher_verification
			 where eVoucher_verification.eVoucher_id = customer_earned_evouchers .earned_evoucher_id
			 Order by eVoucher_verification.created_at DESC) AS verification_code,merchant.merchant_id,
			 eVoucher_transaction.transaction_id,
			  merchant.first_name as m_first_name , merchant.last_name as m_last_name,
			 branch.branch_name,eVoucher_transaction.order_no
			from customer_earned_evouchers JOIN customer ON
			customer_earned_evouchers.customer_id = customer.customer_id
			LEFT JOIN eVoucher_transaction ON eVoucher_transaction.eVoucher_id = customer_earned_evouchers.earned_evoucher_id
			LEFT JOIN merchant ON merchant.merchant_id = eVoucher_transaction.merchant_id
			LEFT JOIN branch ON eVoucher_transaction.branch_code = branch.branch_code
			WHERE  CAST(customer_earned_evouchers.created_at as Date)>= CAST(@start_date  as DATE)
				 AND CAST(customer_earned_evouchers.created_at as DATE) <= CAST(@end_date as DATE)
				 AND customer_earned_evouchers.expired_date >= GETDATE()

				/* AND Lower(customer.first_name + ' ' + customer.last_name) LIKE Lower('%'+ @customer_name +'%') 
				 AND Lower(merchant.first_name + ' ' + merchant.last_name) LIKE Lower('%'+ @merchant_name +'%')
				 AND Lower(customer_earned_evouchers.used_status) LIKE Lower('%'+ @used_status +'%')*/

			--order by eVoucher_transaction.eVoucher_id desc
			order by customer_earned_evouchers.updated_at desc
		
		END
		
END

	ELSE
	
	BEGIN
	
		--if expired status is null
		IF(Lower(LTRIM(RTRIM(@expired_status)))='')
		BEGIN
			INSERT INTO #Customer_eVoucherReport_Table (
			evoucher_id,
			customer_id ,
			eVoucher_code ,
			eVoucher_amount ,
			c_first_name ,
			c_last_name,
			redeemed_winks ,
			created_at ,
			updated_at ,
			used_status ,
			expired_date ,
			branch_code,
			redeemed_on ,
			verification_code ,
			merchant_id ,
			transaction_id ,
			m_first_name ,
			m_last_name ,
			branch_name,
			order_no
			)
			SELECT customer_earned_evouchers.earned_evoucher_id,customer_earned_evouchers.customer_id,customer_earned_evouchers.eVoucher_code,
			customer_earned_evouchers.eVoucher_amount,
			customer.first_name as c_first_name,customer.last_name as c_last_name,
			customer_earned_evouchers.redeemed_winks,
			customer_earned_evouchers.created_at,customer_earned_evouchers.updated_at,
			customer_earned_evouchers.used_status,customer_earned_evouchers.expired_date,
			eVoucher_transaction.branch_code,eVoucher_transaction.created_at as redeemed_on,
			(SELECT Top 1 eVoucher_verification .verification_code from eVoucher_verification
			where eVoucher_verification.eVoucher_id = customer_earned_evouchers .earned_evoucher_id
			Order by eVoucher_verification.created_at DESC) AS verification_code,merchant.merchant_id,
			eVoucher_transaction.transaction_id,
			merchant.first_name as m_first_name , merchant.last_name as m_last_name,
			branch.branch_name,eVoucher_transaction.order_no
			from customer_earned_evouchers JOIN customer ON
			customer_earned_evouchers.customer_id = customer.customer_id
			LEFT JOIN eVoucher_transaction ON eVoucher_transaction.eVoucher_id = customer_earned_evouchers.earned_evoucher_id
			LEFT JOIN merchant ON merchant.merchant_id = eVoucher_transaction.merchant_id
			LEFT JOIN branch ON eVoucher_transaction.branch_code = branch.branch_code
			--order by eVoucher_transaction.transaction_id desc
			/*AND Lower(customer.first_name + ' ' + customer.last_name) LIKE Lower('%'+ @customer_name +'%') 
			AND Lower(merchant.first_name + ' ' + merchant.last_name) LIKE Lower('%'+ @merchant_name +'%')
			AND Lower(customer_earned_evouchers.used_status) LIKE Lower('%'+ @used_status +'%')*/

			order by customer_earned_evouchers.updated_at desc
		END
		
		--if expired status is YES
		IF(Lower(LTRIM(RTRIM(@expired_status)))='yes')
		BEGIN
			INSERT INTO #Customer_eVoucherReport_Table (
			evoucher_id,
			customer_id ,
			eVoucher_code ,
			eVoucher_amount ,
			c_first_name ,
			c_last_name,
			redeemed_winks ,
			created_at ,
			updated_at ,
			used_status ,
			expired_date ,
			branch_code,
			redeemed_on ,
			verification_code ,
			merchant_id ,
			transaction_id ,
			m_first_name ,
			m_last_name ,
			branch_name,
			order_no
			)
			SELECT customer_earned_evouchers.earned_evoucher_id,customer_earned_evouchers.customer_id,customer_earned_evouchers.eVoucher_code,
			customer_earned_evouchers.eVoucher_amount,
			customer.first_name as c_first_name,customer.last_name as c_last_name,
			customer_earned_evouchers.redeemed_winks,
			customer_earned_evouchers.created_at,customer_earned_evouchers.updated_at,
			customer_earned_evouchers.used_status,customer_earned_evouchers.expired_date,
			eVoucher_transaction.branch_code,eVoucher_transaction.created_at as redeemed_on,
			(SELECT Top 1 eVoucher_verification .verification_code from eVoucher_verification
			where eVoucher_verification.eVoucher_id = customer_earned_evouchers .earned_evoucher_id
			Order by eVoucher_verification.created_at DESC) AS verification_code,merchant.merchant_id,
			eVoucher_transaction.transaction_id,
			merchant.first_name as m_first_name , merchant.last_name as m_last_name,
			branch.branch_name,eVoucher_transaction.order_no
			from customer_earned_evouchers JOIN customer ON
			customer_earned_evouchers.customer_id = customer.customer_id
			LEFT JOIN eVoucher_transaction ON eVoucher_transaction.eVoucher_id = customer_earned_evouchers.earned_evoucher_id
			LEFT JOIN merchant ON merchant.merchant_id = eVoucher_transaction.merchant_id
			LEFT JOIN branch ON eVoucher_transaction.branch_code = branch.branch_code
			WHERE customer_earned_evouchers.expired_date < GETDATE()
			--order by eVoucher_transaction.transaction_id desc
			/*AND Lower(customer.first_name + ' ' + customer.last_name) LIKE Lower('%'+ @customer_name +'%') 
			AND Lower(merchant.first_name + ' ' + merchant.last_name) LIKE Lower('%'+ @merchant_name +'%')
			AND Lower(customer_earned_evouchers.used_status) LIKE Lower('%'+ @used_status +'%')*/

			order by customer_earned_evouchers.updated_at desc
		END
		
		--if expired status is NO
		IF(Lower(LTRIM(RTRIM(@expired_status)))='no')
		BEGIN
			INSERT INTO #Customer_eVoucherReport_Table (
			evoucher_id,
			customer_id ,
			eVoucher_code ,
			eVoucher_amount ,
			c_first_name ,
			c_last_name,
			redeemed_winks ,
			created_at ,
			updated_at ,
			used_status ,
			expired_date ,
			branch_code,
			redeemed_on ,
			verification_code ,
			merchant_id ,
			transaction_id ,
			m_first_name ,
			m_last_name ,
			branch_name,
			order_no
			)
			SELECT customer_earned_evouchers.earned_evoucher_id,customer_earned_evouchers.customer_id,customer_earned_evouchers.eVoucher_code,
			customer_earned_evouchers.eVoucher_amount,
			customer.first_name as c_first_name,customer.last_name as c_last_name,
			customer_earned_evouchers.redeemed_winks,
			customer_earned_evouchers.created_at,customer_earned_evouchers.updated_at,
			customer_earned_evouchers.used_status,customer_earned_evouchers.expired_date,
			eVoucher_transaction.branch_code,eVoucher_transaction.created_at as redeemed_on,
			(SELECT Top 1 eVoucher_verification .verification_code from eVoucher_verification
			where eVoucher_verification.eVoucher_id = customer_earned_evouchers .earned_evoucher_id
			Order by eVoucher_verification.created_at DESC) AS verification_code,merchant.merchant_id,
			eVoucher_transaction.transaction_id,
			merchant.first_name as m_first_name , merchant.last_name as m_last_name,
			branch.branch_name,eVoucher_transaction.order_no
			from customer_earned_evouchers JOIN customer ON
			customer_earned_evouchers.customer_id = customer.customer_id
			LEFT JOIN eVoucher_transaction ON eVoucher_transaction.eVoucher_id = customer_earned_evouchers.earned_evoucher_id
			LEFT JOIN merchant ON merchant.merchant_id = eVoucher_transaction.merchant_id
			LEFT JOIN branch ON eVoucher_transaction.branch_code = branch.branch_code
			WHERE customer_earned_evouchers.expired_date >= GETDATE()
			--order by eVoucher_transaction.transaction_id desc
			/*AND Lower(customer.first_name + ' ' + customer.last_name) LIKE Lower('%'+ @customer_name +'%') 
			AND Lower(merchant.first_name + ' ' + merchant.last_name) LIKE Lower('%'+ @merchant_name +'%')
			AND Lower(customer_earned_evouchers.used_status) LIKE Lower('%'+ @used_status +'%')*/

			order by customer_earned_evouchers.updated_at desc
		END

--WHERE  CAST(customer_earned_evouchers.created_at as Date)>= CAST(@start_date  as DATE)
--	 AND CAST(customer_earned_evouchers.created_at as DATE) <= CAST(@end_date as DATE)
	
	END
		
		-- Filter ALl --
		if(@customer_name !='' AND @customer_name IS NOT NULL AND @merchant_name !='' AND @merchant_name IS NOT NULL AND @used_status!='' AND @used_status IS NOT NULL)
			BEGIN
			Select * from #Customer_eVoucherReport_Table AS report where Lower(report.c_first_name + ' ' + report.c_last_name) LIKE Lower('%'+ @customer_name +'%')
			AND Lower(report.m_first_name + ' ' + report.m_last_name) LIKE Lower('%'+ @merchant_name +'%')
			AND report.used_status = @used_status_
			
			order by updated_at desc
			
			END
			-- Filter Customer Name and Merchant 
		ELSE IF (@customer_name !='' AND @merchant_name !='' AND  @used_status ='')
			BEGIN
			Select * from #Customer_eVoucherReport_Table AS report 
			where Lower(report.c_first_name + ' ' + report.c_last_name) LIKE Lower('%'+ @customer_name +'%')
			AND Lower(report.m_first_name + ' ' + report.m_last_name) LIKE Lower('%'+ @merchant_name +'%')
			order by updated_at desc
			END
		-- Filter Customer Name and Used Status 
		ELSE IF (@customer_name !='' AND @merchant_name ='' AND @used_status!='')
			BEGIN
			Select * from #Customer_eVoucherReport_Table AS report 
			where Lower(report.c_first_name + ' ' + report.c_last_name) LIKE Lower('%'+ @customer_name +'%')
			AND report.used_status = @used_status_
			order by updated_at desc
			END
		-- Filter Merchant Name and Used Status 
		
		ELSE IF (@customer_name ='' AND  @merchant_name !='' AND @used_status!='')
			BEGIN
			Select * from #Customer_eVoucherReport_Table AS report 
			where  Lower(report.m_first_name + ' ' + report.m_last_name) LIKE Lower('%'+ @merchant_name +'%')
			AND report.used_status = @used_status_
			order by updated_at desc
			END
		-- Filter Customer Name 
		ELSE IF (@customer_name !='' AND @merchant_name ='' AND @used_status='')
			BEGIN
			Select * from #Customer_eVoucherReport_Table AS report 
			where  Lower(report.c_first_name + ' ' + report.c_last_name) LIKE Lower('%'+ @customer_name +'%')
			order by updated_at desc			
			END
		-- Filter Merchant Name 
		ELSE IF (@customer_name ='' AND @merchant_name !='' AND @used_status ='')
			BEGIN
			Select * from #Customer_eVoucherReport_Table AS report 
			where Lower(report.m_first_name + ' ' + report.m_last_name) LIKE Lower('%'+ @merchant_name +'%')
			order by updated_at desc
			
			END
		-- Filter Used Status
		ELSE IF (@customer_name ='' AND @merchant_name ='' AND @used_status!='')
			BEGIN
			Select * from #Customer_eVoucherReport_Table AS report 
			where report.used_status = @used_status_
			order by updated_at desc
			
			END
		ELSE 
			BEGIN
			Select * from #Customer_eVoucherReport_Table
			order by updated_at desc
			END
		
		


END



