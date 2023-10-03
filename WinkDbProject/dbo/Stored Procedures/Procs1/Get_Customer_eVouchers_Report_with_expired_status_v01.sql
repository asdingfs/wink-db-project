

CREATE PROCEDURE [dbo].[Get_Customer_eVouchers_Report_with_expired_status_v01]
	(@start_date varchar(50),
	 @end_date varchar(50),
	
	@customer_name varchar(50),
	@merchant_name varchar(50),
	@used_status varchar(50),
	@expired_status varchar(50),
	@branch_id varchar(50),
	@evoucher_code varchar(50)
	)
AS
BEGIN

Declare @current_date DateTime

Declare @used_status_ bit

Exec GET_CURRENT_SINGAPORT_DATETIME @current_date output

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
	
-- Create Temp Table
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


/*-----------------------Filter Date ------------------------------*/



/*--- Check By Date ----------------*/

IF (@start_date IS NOT NULL AND @end_date IS NOT NULL AND @start_date!='' AND @end_date !='')

	BEGIN
		 /*----------Filter By Redemption Date -----------------*/
		 
		 ---1. Evoucher is already used and expired
		  If (@used_status_ =1 AND Lower(LTRIM(RTRIM(@expired_status)))='yes')
			BEGIN
			
			select * from #Customer_eVoucherReport_Table
			END
			
		 ---2. Evoucher is already used and with "No" expired or without selection expired status 	
		 ELSE IF(@used_status_ =1 AND (Lower(LTRIM(RTRIM(@expired_status)))='' OR Lower(LTRIM(RTRIM(@expired_status)))='no'))
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

				SELECT customer_earned_evouchers.earned_evoucher_id,
				customer_earned_evouchers.customer_id,
				customer_earned_evouchers.eVoucher_code,
				customer_earned_evouchers.eVoucher_amount,
				customer.first_name as c_first_name,customer.last_name as c_last_name,
				customer_earned_evouchers.redeemed_winks,
				customer_earned_evouchers.created_at,customer_earned_evouchers.updated_at,
				customer_earned_evouchers.used_status,customer_earned_evouchers.expired_date,
				eVoucher_transaction.branch_code,eVoucher_transaction.created_at as redeemed_on,
				eVoucher_transaction.verification_code,merchant.merchant_id,
				eVoucher_transaction.transaction_id,
				merchant.first_name as m_first_name , merchant.last_name as m_last_name,
				branch.branch_name,eVoucher_transaction.order_no
				from customer_earned_evouchers JOIN customer ON
				customer_earned_evouchers.customer_id = customer.customer_id
				JOIN eVoucher_transaction ON eVoucher_transaction.eVoucher_id = customer_earned_evouchers.earned_evoucher_id
				JOIN merchant ON merchant.merchant_id = eVoucher_transaction.merchant_id
				JOIN branch ON eVoucher_transaction.branch_code = branch.branch_code
			   
				WHERE  CAST(eVoucher_transaction.created_at as Date)>= CAST(@start_date  as DATE)
				AND CAST (eVoucher_transaction.created_at as DATE) <= CAST(@end_date as DATE)
				AND customer_earned_evouchers.used_status = 1

			    AND Lower(customer.first_name + ' ' + customer.last_name) LIKE Lower('%'+ @customer_name +'%') 
			    AND Lower(merchant.first_name + ' ' + merchant.last_name) LIKE Lower('%'+ @merchant_name +'%')
                AND ISNULL(lower(eVoucher_transaction.branch_code),'') LIKE lower('%'+ @branch_id +'%')				AND lower(customer_earned_evouchers.eVoucher_code) LIKE lower('%'+ @evoucher_code +'%')

				--order by eVoucher_transaction.eVoucher_id desc
				order by eVoucher_transaction.created_at desc
			
			END
			
			 /*---3.--Filter By Expired Date And "No" used or without used status selection-----------------*/
		 ELSE IF(Lower(LTRIM(RTRIM(@expired_status)))='yes' AND (@used_status='' OR @used_status_=0))  
		
			BEGIN
			Print('Expired By Date')
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
				'',NULL as redeemed_on,
				'','',
				'',
				'' as m_first_name , '' as m_last_name,
				'',''
				from customer_earned_evouchers JOIN customer ON
				customer_earned_evouchers.customer_id = customer.customer_id
			
				WHERE  CAST(customer_earned_evouchers.expired_date as Date)>= CAST(@start_date  as DATE)
				AND 
				CAST(customer_earned_evouchers.expired_date as DATE) <= CAST(@end_date as DATE)
				
				AND 
				CAST(customer_earned_evouchers.expired_date as DATE) != CAST(@current_date as DATE)

				and customer_earned_evouchers.earned_evoucher_id NOT IN (select eVoucher_transaction.eVoucher_id from eVoucher_transaction)
				and customer_earned_evouchers.used_status =0
				
				AND Lower(customer.first_name + ' ' + customer.last_name) LIKE Lower('%'+ @customer_name +'%') 
                AND lower(customer_earned_evouchers.eVoucher_code) LIKE lower('%'+ @evoucher_code +'%')

				--order by eVoucher_transaction.eVoucher_id desc
				order by customer_earned_evouchers.updated_at desc
			
			END
		
		 
		  ---4. Not used and not expired
		ELSE If (@used_status_ =0 AND (Lower(LTRIM(RTRIM(@expired_status)))='no') )
			BEGIN
			Print('(@used_status_ =0)')
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
				'',NULL as redeemed_on,
				'','',
				'',
				'' as m_first_name , '' as m_last_name,
				'',''
				from customer_earned_evouchers JOIN customer ON
				customer_earned_evouchers.customer_id = customer.customer_id
			
				WHERE  CAST(customer_earned_evouchers.created_at as Date)>= CAST(@start_date  as DATE)
				AND CAST(customer_earned_evouchers.created_at as DATE) <= CAST(@end_date as DATE)
				and customer_earned_evouchers.earned_evoucher_id NOT IN (select eVoucher_transaction.eVoucher_id from eVoucher_transaction)
				and customer_earned_evouchers.used_status =0
				and CAST (customer_earned_evouchers.expired_date as DATE) >= Cast (@current_date as date)
				
				AND Lower(customer.first_name + ' ' + customer.last_name) LIKE Lower('%'+ @customer_name +'%') 
				AND lower(customer_earned_evouchers.eVoucher_code) LIKE lower('%'+ @evoucher_code +'%')

				--order by eVoucher_transaction.eVoucher_id desc
				order by customer_earned_evouchers.updated_at desc
			
			END
		-- 5. Not Used and Not selecting the expired	
		ELSE If (@used_status_ =0 AND @expired_status='')
			BEGIN
			Print('(@used_status_ =0)')
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
				'',NULL as redeemed_on,
				'','',
				'',
				'' as m_first_name , '' as m_last_name,
				'',''
				from customer_earned_evouchers JOIN customer ON
				customer_earned_evouchers.customer_id = customer.customer_id
			
				WHERE  CAST(customer_earned_evouchers.created_at as Date)>= CAST(@start_date  as DATE)
				AND CAST(customer_earned_evouchers.created_at as DATE) <= CAST(@end_date as DATE)
				and customer_earned_evouchers.earned_evoucher_id NOT IN (select eVoucher_transaction.eVoucher_id from eVoucher_transaction)
				and customer_earned_evouchers.used_status =0
				AND Lower(customer.first_name + ' ' + customer.last_name) LIKE Lower('%'+ @customer_name +'%') 
				AND lower(customer_earned_evouchers.eVoucher_code) LIKE lower('%'+ @evoucher_code +'%')

				order by customer_earned_evouchers.updated_at desc
			
			END
			
			--- 6. Not expired and Not selected used status or not used  
		ELSE IF(Lower(LTRIM(RTRIM(@expired_status)))='no' AND (@used_status_ =0 OR @used_status='')) 	
			BEGIN
	        Print('No Date Filter Not Expired')
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
			eVoucher_transaction .verification_code,merchant.merchant_id,
			eVoucher_transaction.transaction_id,
			merchant.first_name as m_first_name , merchant.last_name as m_last_name,
			branch.branch_name,eVoucher_transaction.order_no
			from customer_earned_evouchers JOIN customer ON
			customer_earned_evouchers.customer_id = customer.customer_id
			LEFT JOIN eVoucher_transaction ON eVoucher_transaction.eVoucher_id = customer_earned_evouchers.earned_evoucher_id
			LEFT JOIN merchant ON merchant.merchant_id = eVoucher_transaction.merchant_id
			LEFT JOIN branch ON eVoucher_transaction.branch_code = branch.branch_code
			Where
			CAST(customer_earned_evouchers.created_at as Date)>= CAST(@start_date  as DATE)
				AND CAST(customer_earned_evouchers.created_at as DATE) <= CAST(@end_date as DATE)
				AND
			 Lower(customer.first_name + ' ' + customer.last_name) LIKE Lower('%'+ @customer_name +'%') 
			and customer_earned_evouchers.used_status = 0
			--AND Lower(merchant.first_name + ' ' + merchant.last_name) LIKE Lower('%'+ @merchant_name +'%')
			and CAST (customer_earned_evouchers.expired_date as DATE) >= Cast (@current_date as date)
            AND ISNULL(lower(eVoucher_transaction.branch_code),'') LIKE lower('%'+ @branch_id +'%')			AND lower(customer_earned_evouchers.eVoucher_code) LIKE lower('%'+ @evoucher_code +'%')

			order by customer_earned_evouchers.updated_at desc
			END
		
	    ELSE
	    -- Not filter anything
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
			eVoucher_transaction.verification_code,merchant.merchant_id,
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
			AND Lower(customer.first_name + ' ' + customer.last_name) LIKE Lower('%'+ @customer_name +'%') 
			AND ISNULL(lower(eVoucher_transaction.branch_code),'') LIKE lower('%'+ @branch_id +'%')
			AND lower(customer_earned_evouchers.eVoucher_code) LIKE lower('%'+ @evoucher_code +'%')

			--AND Lower(merchant.first_name + ' ' + merchant.last_name) LIKE Lower('%'+ @merchant_name +'%')
				
			order by customer_earned_evouchers.updated_at desc

		END 
	    
	
	END --- Filter date
ELSE 

	BEGIN
	         -------------No Date Filter ----------------------------------
	         Print('No Date Filter')
	         ----1. eVoucher is expired and used 
	        If (@used_status_ =1 AND Lower(LTRIM(RTRIM(@expired_status)))='yes')
			BEGIN
			
			select * from #Customer_eVoucherReport_Table
			END
			--2. Not selecting expird status and used status 
	       ELSE IF (@used_status ='' AND @expired_status ='')
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
			eVoucher_transaction.verification_code,merchant.merchant_id,
			eVoucher_transaction.transaction_id,
			merchant.first_name as m_first_name , merchant.last_name as m_last_name,
			branch.branch_name,eVoucher_transaction.order_no
			from customer_earned_evouchers JOIN customer ON
			customer_earned_evouchers.customer_id = customer.customer_id
			LEFT JOIN eVoucher_transaction ON eVoucher_transaction.eVoucher_id = customer_earned_evouchers.earned_evoucher_id
			LEFT JOIN merchant ON merchant.merchant_id = eVoucher_transaction.merchant_id
			LEFT JOIN branch ON eVoucher_transaction.branch_code = branch.branch_code
			Where Lower(customer.first_name + ' ' + customer.last_name) LIKE Lower('%'+ @customer_name +'%') 
			--AND Lower(merchant.first_name + ' ' + merchant.last_name) LIKE Lower('%'+ @merchant_name +'%')
			AND ISNULL(lower(eVoucher_transaction.branch_code),'') LIKE lower('%'+ @branch_id +'%')
            AND lower(customer_earned_evouchers.eVoucher_code) LIKE lower('%'+ @evoucher_code +'%')

			order by customer_earned_evouchers.updated_at desc
			END
			---3.-- Expird eVoucher
		   ELSE IF(Lower(LTRIM(RTRIM(@expired_status)))='yes' AND (@used_status='' OR @used_status_=0))  
			BEGIN
	       Print('Expired Yes')
	        Print (@current_date)
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
			eVoucher_transaction.verification_code,merchant.merchant_id,
			eVoucher_transaction.transaction_id,
			merchant.first_name as m_first_name , merchant.last_name as m_last_name,
			branch.branch_name,eVoucher_transaction.order_no
			from customer_earned_evouchers JOIN customer ON
			customer_earned_evouchers.customer_id = customer.customer_id
			LEFT JOIN eVoucher_transaction ON eVoucher_transaction.eVoucher_id = customer_earned_evouchers.earned_evoucher_id
			LEFT JOIN merchant ON merchant.merchant_id = eVoucher_transaction.merchant_id
			LEFT JOIN branch ON eVoucher_transaction.branch_code = branch.branch_code
			Where 
			CAST (customer_earned_evouchers.expired_date as DATE) < Cast (@current_date as date)
			AND Lower(customer.first_name + ' ' + customer.last_name) LIKE Lower('%'+ @customer_name +'%') 
			and customer_earned_evouchers.earned_evoucher_id NOT IN (select eVoucher_transaction.eVoucher_id from eVoucher_transaction)
			and customer_earned_evouchers.used_status =0
			--AND lower(eVoucher_transaction.branch_code) LIKE lower('%'+ @branch_id +'%')
	        AND lower(customer_earned_evouchers.eVoucher_code) LIKE lower('%'+ @evoucher_code +'%')

			--AND Lower(merchant.first_name + ' ' + merchant.last_name) LIKE Lower('%'+ @merchant_name +'%')
			
			
			order by customer_earned_evouchers.updated_at desc
			END
	
		-- 4. Not used and Not selecting expired status 
		  ELSE IF(@used_status_ =0 AND @expired_status ='') 
			BEGIN
	        Print('no datetime filter used')
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
			eVoucher_transaction.verification_code,merchant.merchant_id,
			eVoucher_transaction.transaction_id,
			merchant.first_name as m_first_name , merchant.last_name as m_last_name,
			branch.branch_name,eVoucher_transaction.order_no
			from customer_earned_evouchers JOIN customer ON
			customer_earned_evouchers.customer_id = customer.customer_id
			LEFT JOIN eVoucher_transaction ON eVoucher_transaction.eVoucher_id = customer_earned_evouchers.earned_evoucher_id
			LEFT JOIN merchant ON merchant.merchant_id = eVoucher_transaction.merchant_id
			LEFT JOIN branch ON eVoucher_transaction.branch_code = branch.branch_code
			Where Lower(customer.first_name + ' ' + customer.last_name) LIKE Lower('%'+ @customer_name +'%') 
			and customer_earned_evouchers.used_status = 0
			AND lower(customer_earned_evouchers.eVoucher_code) LIKE lower('%'+ @evoucher_code +'%')

			--and CAST (customer_earned_evouchers.expired_date as DATE) >= Cast (@current_date as date)
			--AND Lower(merchant.first_name + ' ' + merchant.last_name) LIKE Lower('%'+ @merchant_name +'%')
			order by customer_earned_evouchers.updated_at desc
			END
		   -- 6.. Not used and not expired
		   ELSE IF(@used_status_ =0 AND Lower(LTRIM(RTRIM(@expired_status)))='no')
			BEGIN
	        Print('no datetime filter used')
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
			eVoucher_transaction.verification_code,merchant.merchant_id,
			eVoucher_transaction.transaction_id,
			merchant.first_name as m_first_name , merchant.last_name as m_last_name,
			branch.branch_name,eVoucher_transaction.order_no
			from customer_earned_evouchers JOIN customer ON
			customer_earned_evouchers.customer_id = customer.customer_id
			LEFT JOIN eVoucher_transaction ON eVoucher_transaction.eVoucher_id = customer_earned_evouchers.earned_evoucher_id
			LEFT JOIN merchant ON merchant.merchant_id = eVoucher_transaction.merchant_id
			LEFT JOIN branch ON eVoucher_transaction.branch_code = branch.branch_code
			Where Lower(customer.first_name + ' ' + customer.last_name) LIKE Lower('%'+ @customer_name +'%') 
			and customer_earned_evouchers.used_status = 0
			and CAST (customer_earned_evouchers.expired_date as DATE) >= Cast (@current_date as date)
			AND lower(customer_earned_evouchers.eVoucher_code) LIKE lower('%'+ @evoucher_code +'%')

			--AND Lower(merchant.first_name + ' ' + merchant.last_name) LIKE Lower('%'+ @merchant_name +'%')
			order by customer_earned_evouchers.updated_at desc
			END
		  -- 7. Used and Not expired or not selecting expired
		  ELSE IF(@used_status_ =1 AND (Lower(LTRIM(RTRIM(@expired_status)))='' OR Lower(LTRIM(RTRIM(@expired_status)))='no') )		
			BEGIN
	        Print('no datetime filter used')
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
			eVoucher_transaction.verification_code,merchant.merchant_id,
			eVoucher_transaction.transaction_id,
			merchant.first_name as m_first_name , merchant.last_name as m_last_name,
			branch.branch_name,eVoucher_transaction.order_no
			from customer_earned_evouchers JOIN customer ON
			customer_earned_evouchers.customer_id = customer.customer_id
			LEFT JOIN eVoucher_transaction ON eVoucher_transaction.eVoucher_id = customer_earned_evouchers.earned_evoucher_id
			LEFT JOIN merchant ON merchant.merchant_id = eVoucher_transaction.merchant_id
			LEFT JOIN branch ON eVoucher_transaction.branch_code = branch.branch_code
			Where Lower(customer.first_name + ' ' + customer.last_name) LIKE Lower('%'+ @customer_name +'%') 
			and customer_earned_evouchers.used_status = 1
			AND ISNULL(lower(eVoucher_transaction.branch_code),'') LIKE lower('%'+ @branch_id +'%')
			AND lower(customer_earned_evouchers.eVoucher_code) LIKE lower('%'+ @evoucher_code +'%')

			--AND Lower(merchant.first_name + ' ' + merchant.last_name) LIKE Lower('%'+ @merchant_name +'%')
			order by customer_earned_evouchers.updated_at desc
			END
			-- 7. Not expired And Not Used or Not selecting used status
			ELSE IF(Lower(LTRIM(RTRIM(@expired_status)))='no' AND (@used_status_ =0 OR @used_status='')) 	
			BEGIN
	        Print('No Date Filter Not Expired')
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
			eVoucher_transaction.verification_code,merchant.merchant_id,
			eVoucher_transaction.transaction_id,
			merchant.first_name as m_first_name , merchant.last_name as m_last_name,
			branch.branch_name,eVoucher_transaction.order_no
			from customer_earned_evouchers JOIN customer ON
			customer_earned_evouchers.customer_id = customer.customer_id
			LEFT JOIN eVoucher_transaction ON eVoucher_transaction.eVoucher_id = customer_earned_evouchers.earned_evoucher_id
			LEFT JOIN merchant ON merchant.merchant_id = eVoucher_transaction.merchant_id
			LEFT JOIN branch ON eVoucher_transaction.branch_code = branch.branch_code
			Where Lower(customer.first_name + ' ' + customer.last_name) LIKE Lower('%'+ @customer_name +'%') 
			and customer_earned_evouchers.used_status = 0
			AND lower(customer_earned_evouchers.eVoucher_code) LIKE lower('%'+ @evoucher_code +'%')
			
			--AND Lower(merchant.first_name + ' ' + merchant.last_name) LIKE Lower('%'+ @merchant_name +'%')
			and 	CAST (customer_earned_evouchers.expired_date as DATE) >= Cast (@current_date as date)
			order by customer_earned_evouchers.updated_at desc
			END
			
			ELSE -- 8. Not Filter anything
			
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
			eVoucher_transaction.verification_code,merchant.merchant_id,
			eVoucher_transaction.transaction_id,
			merchant.first_name as m_first_name , merchant.last_name as m_last_name,
			branch.branch_name,eVoucher_transaction.order_no
			from customer_earned_evouchers JOIN customer ON
			customer_earned_evouchers.customer_id = customer.customer_id
			LEFT JOIN eVoucher_transaction ON eVoucher_transaction.eVoucher_id = customer_earned_evouchers.earned_evoucher_id
			LEFT JOIN merchant ON merchant.merchant_id = eVoucher_transaction.merchant_id
			LEFT JOIN branch ON eVoucher_transaction.branch_code = branch.branch_code
			WHERE  
			--CAST(customer_earned_evouchers.created_at as Date)>= CAST(@start_date  as DATE)
			--AND CAST(customer_earned_evouchers.created_at as DATE) <= CAST(@end_date as DATE)
			 Lower(customer.first_name + ' ' + customer.last_name) LIKE Lower('%'+ @customer_name +'%') 
			AND ISNULL(lower(eVoucher_transaction.branch_code),'') LIKE lower('%'+ @branch_id +'%')
			AND lower(customer_earned_evouchers.eVoucher_code) LIKE lower('%'+ @evoucher_code +'%')

			--AND Lower(merchant.first_name + ' ' + merchant.last_name) LIKE Lower('%'+ @merchant_name +'%')
				
			order by customer_earned_evouchers.updated_at desc

		END 
	    
						

		END

		/*
		-- Filter Merchant Name
	    IF (@merchant_name !='')
		BEGIN
		    
			Select * from #Customer_eVoucherReport_Table AS report 
			where Lower(report.m_first_name + ' ' + report.m_last_name) LIKE Lower('%'+ @merchant_name +'%')
			order by updated_at desc
			
		END
		ELSE 
		BEGIN
			Select * from #Customer_eVoucherReport_Table
			order by updated_at desc
		END
		*/
	
		/*	
		-- Filter Merchant Name
	    IF (@merchant_name !='')
		BEGIN
		    
			Select * from #Customer_eVoucherReport_Table AS report 
			left join NETs_CANID_Redemption_Record_Detail as nets
			on report.evoucher_id = nets.evoucher_id
			and nets.cronjob_status = 'done'
			where Lower(report.m_first_name + ' ' + report.m_last_name) LIKE Lower('%'+ @merchant_name +'%')
			order by report.updated_at desc
			
		END
		ELSE 
		BEGIN
			Select * from #Customer_eVoucherReport_Table AS report 
			left join NETs_CANID_Redemption_Record_Detail as nets
			on report.evoucher_id = nets.evoucher_id
			and nets.cronjob_status = 'done'
			order by report.updated_at desc
		END
		*/

		/*
		IF (@merchant_name !='')
		BEGIN
		    
			Select * from #Customer_eVoucherReport_Table report
			left join 		
			(
				Select r.evoucher_id from #Customer_eVoucherReport_Table AS r 
				inner join wink_fee as f
				on r.merchant_id = f.merchant_id
				inner join NETs_CANID_Redemption_Record_Detail as nets
				on r.evoucher_id = nets.evoucher_id
				and nets.cronjob_status = 'done'
			) temp
			on report.evoucher_id = temp.evoucher_id
			where report.merchant_id not in (select merchant_id from wink_fee)
			and Lower(report.m_first_name + ' ' + report.m_last_name) LIKE Lower('%'+ @merchant_name +'%')
			order by report.updated_at desc
			
		END
		ELSE 
		BEGIN
			Select * from #Customer_eVoucherReport_Table report
			left join 		
			(
				Select r.evoucher_id from #Customer_eVoucherReport_Table AS r 
				inner join wink_fee as f
				on r.merchant_id = f.merchant_id
				inner join NETs_CANID_Redemption_Record_Detail as nets
				on r.evoucher_id = nets.evoucher_id
				and nets.cronjob_status = 'done'
			) temp
			on report.evoucher_id = temp.evoucher_id
			order by report.updated_at desc
			--where report.merchant_id not in (select merchant_id from wink_fee)
		END
		*/

		
		-- Filter Merchant Name
	    IF (@merchant_name !='')
		BEGIN

			select * from
			(
				Select report.* from #Customer_eVoucherReport_Table AS report 
				where report.merchant_id not in (select merchant_id from wink_fee)

				union
		    
				Select report.* from #Customer_eVoucherReport_Table AS report 
				inner join NETs_CANID_Redemption_Record_Detail as nets
				on report.evoucher_id = nets.evoucher_id
				and nets.cronjob_status = 'done'
			) as temp	
			where Lower(temp.m_first_name + ' ' + temp.m_last_name) LIKE Lower('%'+ @merchant_name +'%')
			order by temp.updated_at desc
			
		END
		ELSE 
		BEGIN
			select * from
			(
				Select report.* from #Customer_eVoucherReport_Table AS report 
				where report.merchant_id not in (select merchant_id from wink_fee)

				union
		    
				Select report.* from #Customer_eVoucherReport_Table AS report 
				inner join NETs_CANID_Redemption_Record_Detail as nets
				on report.evoucher_id = nets.evoucher_id
				and nets.cronjob_status = 'done'
			) as temp	
			order by temp.updated_at desc
		END
		
		
END



