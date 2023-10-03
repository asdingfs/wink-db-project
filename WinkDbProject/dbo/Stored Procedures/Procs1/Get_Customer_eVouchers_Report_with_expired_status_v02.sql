

CREATE PROCEDURE [dbo].[Get_Customer_eVouchers_Report_with_expired_status_v02]
	(@start_date varchar(50),
	 @end_date varchar(50),
	@customer_id int,
	@wid varchar(50),
	@customer_name varchar(50),
	@used_status varchar(50),
	@expired_status varchar(50),
	@branch_id varchar(50),
	@evoucher_code varchar(50),
	@branch_name varchar(50)
	)
AS
BEGIN
	SET NOCOUNT ON
	Declare @current_date DateTime

	Declare @used_status_ bit

	Print (@branch_name)

	IF(@customer_id = 0)
		SET @customer_id = NULL;

	If(@branch_name is null or @branch_name ='')
	BEGIN
		set @branch_name = NULL;

	END
	IF(@wid is null or @wid ='')
	BEGIN
		SET @wid = NULL;
	END
	IF(@customer_name is null or @customer_name = '')
	BEGIN
		set @customer_name = NULL;

	END
	IF(@branch_id is null or @branch_id = '')
	BEGIN
		set @branch_id = NULL;
	END
	IF(@evoucher_code is null or @evoucher_code = '')
	BEGIN
		set @evoucher_code = NULL;
	END
	Exec GET_CURRENT_SINGAPORT_DATETIME @current_date output

	
	IF (@used_status != '')
	Begin
		IF(Lower(LTRIM(RTRIM(@used_status)))='yes')
		begin
			SET @used_status_ = 1;
		end
		else 
		begin
			SET @used_status_ = 0;
		end
	END
	
-- Create Temp Table
IF OBJECT_ID('tempdb..#Customer_eVoucherReport_Table') IS NOT NULL DROP TABLE #Customer_eVoucherReport_Table

	CREATE TABLE #Customer_eVoucherReport_Table
	(
	 --evoucher_id int,
	 customer_id int,
	 wid varchar(50),
	 eVoucher_code varchar(200),
	 eVoucher_amount decimal(10,2),
	 c_first_name varchar(100),
	 c_last_name varchar(100),
	 --redeemed_winks int,
	 created_at DateTime,
	 updated_at DateTime,
	 used_status Bit,
	 expired_date DateTime,
	 branch_code varchar(100) ,
	 redeemed_on DateTime,
	 --verification_code varchar(100),
	 --merchant_id int,
	 --transaction_id int,
	 --m_first_name varchar(100),
	 --m_last_name varchar(100),
	 branch_name varchar(100)
	 --order_no varchar(50)
 
	)


/*-----------------------Filter Date ------------------------------*/



/*--- Check By Date ----------------*/

IF (@start_date IS NOT NULL AND @end_date IS NOT NULL AND @start_date!='' AND @end_date !='')

	BEGIN
		 /*----------Filter By Redemption Date -----------------*/
		 
		 ---1. Evoucher is already used and expired
		  If (@used_status_ =1 AND Lower(LTRIM(RTRIM(@expired_status)))='yes')
			BEGIN
			
			INSERT INTO #Customer_eVoucherReport_Table (
				--evoucher_id,
			customer_id ,
			wid,
			eVoucher_code ,
			eVoucher_amount ,
			c_first_name ,
			c_last_name,
			--redeemed_winks ,
			created_at ,
			updated_at ,
			used_status ,
			expired_date ,
			branch_code,
			redeemed_on ,
			--verification_code ,
			--merchant_id ,
			--transaction_id ,
			--m_first_name ,
			--m_last_name ,
			branch_name
			--order_no
				
				)

				SELECT customer_earned_evouchers.customer_id,customer.WID as wid, customer_earned_evouchers.eVoucher_code,
			customer_earned_evouchers.eVoucher_amount,
			customer.first_name as c_first_name,customer.last_name as c_last_name,
			customer_earned_evouchers.created_at,customer_earned_evouchers.updated_at,
			customer_earned_evouchers.used_status,customer_earned_evouchers.expired_date,
			eVoucher_transaction.branch_code,eVoucher_transaction.created_at as redeemed_on,
			branch.branch_name
			from customer_earned_evouchers JOIN customer ON
			customer_earned_evouchers.customer_id = customer.customer_id
			LEFT JOIN eVoucher_transaction ON eVoucher_transaction.eVoucher_id = customer_earned_evouchers.earned_evoucher_id
			LEFT JOIN branch ON eVoucher_transaction.branch_code = branch.branch_code
				
				
				WHERE 
			(@customer_name is null or (Lower(customer.first_name + ' ' + customer.last_name) LIKE Lower('%'+ @customer_name +'%'))) 
			AND (@customer_id is null or customer.customer_id = @customer_id)
			AND (@wid is null or customer.WID like '%'+@wid+'%')
			AND (@branch_id is null or (lower(eVoucher_transaction.branch_code) LIKE lower('%'+ @branch_id +'%'))) 
            AND (@evoucher_code is null or (lower(customer_earned_evouchers.eVoucher_code) LIKE lower('%'+ @evoucher_code +'%')))
            and ( @branch_name is null OR branch.branch_name like '%'+@branch_name +'%')
			and	customer_earned_evouchers.used_status = 1
			and CAST(customer_earned_evouchers.expired_date as date) < CAST(@current_date as DATE)
			and CAST(eVoucher_transaction.created_at as Date)>= CAST(@start_date  as DATE)
				AND CAST (eVoucher_transaction.created_at as DATE) <= CAST(@end_date as DATE)
				order by customer_earned_evouchers.updated_at desc
			END
			
		 ---2. Evoucher is already used and with "No" expired or without selection expired status 	
		 ELSE IF(@used_status_ =1 AND (Lower(LTRIM(RTRIM(@expired_status)))='' OR Lower(LTRIM(RTRIM(@expired_status)))='no'))
			BEGIN
			
			INSERT INTO #Customer_eVoucherReport_Table (
				--evoucher_id,
				customer_id ,
				wid,
				eVoucher_code ,
				eVoucher_amount ,
				c_first_name ,
				c_last_name,
				--redeemed_winks ,
				created_at ,
				updated_at ,
				used_status ,
				expired_date ,
				branch_code,
				redeemed_on ,
				--verification_code ,
				--merchant_id ,
				--transaction_id ,
				--m_first_name ,
				--m_last_name ,
				branch_name
				--order_no
				)

				SELECT 
				customer_earned_evouchers.customer_id,
				customer.WID as wid,
				customer_earned_evouchers.eVoucher_code,
				customer_earned_evouchers.eVoucher_amount,
				customer.first_name as c_first_name,customer.last_name as c_last_name,
				customer_earned_evouchers.created_at,customer_earned_evouchers.updated_at,
				customer_earned_evouchers.used_status,customer_earned_evouchers.expired_date,
				eVoucher_transaction.branch_code,eVoucher_transaction.created_at as redeemed_on,
				branch.branch_name
				from customer_earned_evouchers JOIN customer ON
				customer_earned_evouchers.customer_id = customer.customer_id
				JOIN eVoucher_transaction ON eVoucher_transaction.eVoucher_id = customer_earned_evouchers.earned_evoucher_id
				JOIN branch ON 
				eVoucher_transaction.branch_code = branch.branch_code
				WHERE  CAST(eVoucher_transaction.created_at as Date)>= CAST(@start_date  as DATE)
				AND CAST (eVoucher_transaction.created_at as DATE) <= CAST(@end_date as DATE)
				AND customer_earned_evouchers.used_status = 1

				AND (@customer_id is null or customer.customer_id = @customer_id)
				AND (@wid is null or customer.WID like '%'+@wid+'%')
			    AND (@customer_name is null or (Lower(customer.first_name + ' ' + customer.last_name) LIKE Lower('%'+ @customer_name +'%'))) 
                AND (@branch_id is null or (lower(eVoucher_transaction.branch_code) LIKE lower('%'+ @branch_id +'%'))) 
				AND (@evoucher_code is null or (lower(customer_earned_evouchers.eVoucher_code) LIKE lower('%'+ @evoucher_code +'%')))
				and ( @branch_name is null OR branch.branch_name like '%'+@branch_name +'%')

				order by eVoucher_transaction.created_at desc
			
			END
			
			 /*---3.--Filter By Expired Date And "No" used or without used status selection-----------------*/
		 ELSE IF(Lower(LTRIM(RTRIM(@expired_status)))='yes' AND (@used_status='' OR @used_status_=0))  
		
			BEGIN
			Print('Expired By Date')
			INSERT INTO #Customer_eVoucherReport_Table (
				--evoucher_id,
				customer_id ,
				wid,
				eVoucher_code ,
				eVoucher_amount ,
				c_first_name ,
				c_last_name,
				--redeemed_winks ,
				created_at ,
				updated_at ,
				used_status ,
				expired_date ,
				branch_code,
				redeemed_on ,
				--verification_code ,
				--merchant_id ,
				--transaction_id ,
				--m_first_name ,
				--m_last_name ,
				branch_name
				--order_no
				)

				SELECT customer_earned_evouchers.customer_id,customer.WID as wid, customer_earned_evouchers.eVoucher_code,
				customer_earned_evouchers.eVoucher_amount,
				customer.first_name as c_first_name,customer.last_name as c_last_name,
				customer_earned_evouchers.created_at,customer_earned_evouchers.updated_at,
				customer_earned_evouchers.used_status,customer_earned_evouchers.expired_date,
				'',NULL as redeemed_on,
				''
				from customer_earned_evouchers JOIN customer ON
				customer_earned_evouchers.customer_id = customer.customer_id
			
				WHERE  CAST(customer_earned_evouchers.expired_date as Date)>= CAST(@start_date  as DATE)
				AND 
				CAST(customer_earned_evouchers.expired_date as DATE) <= CAST(@end_date as DATE)
				
				AND 
				CAST(customer_earned_evouchers.expired_date as DATE) < CAST(@current_date as DATE)

				and customer_earned_evouchers.earned_evoucher_id NOT IN (select eVoucher_transaction.eVoucher_id from eVoucher_transaction)
				and customer_earned_evouchers.used_status =0
				
				AND (@customer_id is null or customer.customer_id = @customer_id)
				AND (@wid is null or customer.WID like '%'+@wid+'%')
				AND (@customer_name is null or (Lower(customer.first_name + ' ' + customer.last_name) LIKE Lower('%'+ @customer_name +'%'))) 
                AND (@evoucher_code is null or (lower(customer_earned_evouchers.eVoucher_code) LIKE lower('%'+ @evoucher_code +'%')))
				order by customer_earned_evouchers.updated_at desc
			
			END
		
		 
		  ---4. Not used and not expired
		ELSE If (@used_status_ =0 AND (Lower(LTRIM(RTRIM(@expired_status)))='no') )
			BEGIN
		
			INSERT INTO #Customer_eVoucherReport_Table (
				--evoucher_id,
				customer_id ,
				wid,
				eVoucher_code ,
				eVoucher_amount ,
				c_first_name ,
				c_last_name,
				--redeemed_winks ,
				created_at ,
				updated_at ,
				used_status ,
				expired_date ,
				branch_code,
				redeemed_on ,
				--verification_code ,
				--merchant_id ,
				--transaction_id ,
				--m_first_name ,
				--m_last_name ,
				branch_name
				--order_no
				)

				SELECT customer_earned_evouchers.customer_id,customer.WID as wid, customer_earned_evouchers.eVoucher_code,
				customer_earned_evouchers.eVoucher_amount,
				customer.first_name as c_first_name,customer.last_name as c_last_name,
				customer_earned_evouchers.created_at,customer_earned_evouchers.updated_at,
				customer_earned_evouchers.used_status,customer_earned_evouchers.expired_date,
				'',NULL as redeemed_on,
				''
				from customer_earned_evouchers JOIN customer ON
				customer_earned_evouchers.customer_id = customer.customer_id
			
				WHERE  CAST(customer_earned_evouchers.created_at as Date)>= CAST(@start_date  as DATE)
				AND CAST(customer_earned_evouchers.created_at as DATE) <= CAST(@end_date as DATE)
				and customer_earned_evouchers.earned_evoucher_id NOT IN (select eVoucher_transaction.eVoucher_id from eVoucher_transaction)
				and customer_earned_evouchers.used_status =0
				and CAST (customer_earned_evouchers.expired_date as DATE) >= Cast (@current_date as date)
				
				AND (@customer_id is null or customer.customer_id = @customer_id)
				AND (@wid is null or customer.WID like '%'+@wid+'%')
				AND (@customer_name is null or (Lower(customer.first_name + ' ' + customer.last_name) LIKE Lower('%'+ @customer_name +'%'))) 
				AND (@evoucher_code is null or (lower(customer_earned_evouchers.eVoucher_code) LIKE lower('%'+ @evoucher_code +'%')))

				order by customer_earned_evouchers.updated_at desc
			
			END
		-- 5. Not Used and Not selecting the expired	
		ELSE If (@used_status_ =0 AND (@expired_status is null or @expired_status = ''))
			BEGIN
			Print('(@used_status_ =0)')
			INSERT INTO #Customer_eVoucherReport_Table (
				--evoucher_id,
				customer_id ,
				wid,
				eVoucher_code ,
				eVoucher_amount ,
				c_first_name ,
				c_last_name,
				--redeemed_winks ,
				created_at ,
				updated_at ,
				used_status ,
				expired_date ,
				branch_code,
				redeemed_on ,
				--verification_code ,
				--merchant_id ,
				--transaction_id ,
				--m_first_name ,
				--m_last_name ,
				branch_name
				--order_no
				)

				SELECT customer_earned_evouchers.customer_id,customer.WID as wid, customer_earned_evouchers.eVoucher_code,
				customer_earned_evouchers.eVoucher_amount,
				customer.first_name as c_first_name,customer.last_name as c_last_name,
				customer_earned_evouchers.created_at,customer_earned_evouchers.updated_at,
				customer_earned_evouchers.used_status,customer_earned_evouchers.expired_date,
				'',NULL as redeemed_on,
				''
				from customer_earned_evouchers JOIN customer ON
				customer_earned_evouchers.customer_id = customer.customer_id
			
				WHERE  CAST(customer_earned_evouchers.created_at as Date)>= CAST(@start_date  as DATE)
				AND CAST(customer_earned_evouchers.created_at as DATE) <= CAST(@end_date as DATE)
				and customer_earned_evouchers.earned_evoucher_id NOT IN (select eVoucher_transaction.eVoucher_id from eVoucher_transaction)
				and customer_earned_evouchers.used_status =0
				AND (@customer_id is null or customer.customer_id = @customer_id)
				AND (@wid is null or customer.WID like '%'+@wid+'%')
				AND (@customer_name is null or (Lower(customer.first_name + ' ' + customer.last_name) LIKE Lower('%'+ @customer_name +'%'))) 
				AND (@evoucher_code is null or (lower(customer_earned_evouchers.eVoucher_code) LIKE lower('%'+ @evoucher_code +'%')))

				order by customer_earned_evouchers.updated_at desc
			
			END
			
			--- 6. Not expired and Not selected used status or not used  
		ELSE IF(Lower(LTRIM(RTRIM(@expired_status)))='no' AND (@used_status_ =0 OR @used_status='')) 	
			BEGIN
	        Print('No Date Filter Not Expired')
			INSERT INTO #Customer_eVoucherReport_Table (
			--evoucher_id,
				customer_id ,
				wid,
				eVoucher_code ,
				eVoucher_amount ,
				c_first_name ,
				c_last_name,
				--redeemed_winks ,
				created_at ,
				updated_at ,
				used_status ,
				expired_date ,
				branch_code,
				redeemed_on ,
				--verification_code ,
				--merchant_id ,
				--transaction_id ,
				--m_first_name ,
				--m_last_name ,
				branch_name
				--order_no
				)
			SELECT customer_earned_evouchers.customer_id,customer.WID as wid,customer_earned_evouchers.eVoucher_code,
			customer_earned_evouchers.eVoucher_amount,
			customer.first_name as c_first_name,customer.last_name as c_last_name,
			customer_earned_evouchers.created_at,customer_earned_evouchers.updated_at,
			customer_earned_evouchers.used_status,customer_earned_evouchers.expired_date,
			eVoucher_transaction.branch_code,eVoucher_transaction.created_at as redeemed_on,
			branch.branch_name
			from customer_earned_evouchers JOIN customer ON
			customer_earned_evouchers.customer_id = customer.customer_id
			LEFT JOIN eVoucher_transaction ON eVoucher_transaction.eVoucher_id = customer_earned_evouchers.earned_evoucher_id
			LEFT JOIN branch ON eVoucher_transaction.branch_code = branch.branch_code

			Where
			CAST(customer_earned_evouchers.created_at as Date)>= CAST(@start_date  as DATE)
				AND CAST(customer_earned_evouchers.created_at as DATE) <= CAST(@end_date as DATE)

				AND (@customer_id is null or customer.customer_id = @customer_id)
				AND (@wid is null or customer.WID like '%'+@wid+'%')
			AND (@customer_name is null or (Lower(customer.first_name + ' ' + customer.last_name) LIKE Lower('%'+ @customer_name +'%'))) 
			and customer_earned_evouchers.used_status = 0
			and CAST (customer_earned_evouchers.expired_date as DATE) >= Cast (@current_date as date)
			AND (@branch_id is null or (lower(eVoucher_transaction.branch_code) LIKE lower('%'+ @branch_id +'%'))) 	
			AND (@evoucher_code is null or (lower(customer_earned_evouchers.eVoucher_code) LIKE lower('%'+ @evoucher_code +'%')))
			and ( @branch_name is null OR branch.branch_name like '%'+@branch_name +'%')

			order by customer_earned_evouchers.updated_at desc
			END
		
	    ELSE
	    -- Not filter anything
	     BEGIN
			INSERT INTO #Customer_eVoucherReport_Table (
			--evoucher_id,
			customer_id ,
			wid,
			eVoucher_code ,
			eVoucher_amount ,
			c_first_name ,
			c_last_name,
			--redeemed_winks ,
			created_at ,
			updated_at ,
			used_status ,
			expired_date ,
			branch_code,
			redeemed_on ,
			--verification_code ,
			--merchant_id ,
			--transaction_id ,
			--m_first_name ,
			--m_last_name ,
			branch_name
			--order_no
			)
			SELECT customer_earned_evouchers.customer_id,customer.WID as wid, customer_earned_evouchers.eVoucher_code,
			customer_earned_evouchers.eVoucher_amount,
			customer.first_name as c_first_name,customer.last_name as c_last_name,
			customer_earned_evouchers.created_at,customer_earned_evouchers.updated_at,
			customer_earned_evouchers.used_status,customer_earned_evouchers.expired_date,
			eVoucher_transaction.branch_code,eVoucher_transaction.created_at as redeemed_on,
			branch.branch_name
			from customer_earned_evouchers JOIN customer ON
			customer_earned_evouchers.customer_id = customer.customer_id
			LEFT JOIN eVoucher_transaction ON eVoucher_transaction.eVoucher_id = customer_earned_evouchers.earned_evoucher_id
			LEFT JOIN branch ON eVoucher_transaction.branch_code = branch.branch_code

			WHERE  CAST(customer_earned_evouchers.updated_at as Date)>= CAST(@start_date  as DATE)
			AND CAST(customer_earned_evouchers.updated_at as DATE) <= CAST(@end_date as DATE)
			AND (@customer_id is null or customer.customer_id = @customer_id)
			AND (@wid is null or customer.WID like '%'+@wid+'%')
			AND (@customer_name is null or (Lower(customer.first_name + ' ' + customer.last_name) LIKE Lower('%'+ @customer_name +'%'))) 
			AND (@branch_id is null or (lower(eVoucher_transaction.branch_code) LIKE lower('%'+ @branch_id +'%'))) 
			AND (@evoucher_code is null or (lower(customer_earned_evouchers.eVoucher_code) LIKE lower('%'+ @evoucher_code +'%')))
			and ( @branch_name is null OR branch.branch_name like '%'+@branch_name +'%')
			order by customer_earned_evouchers.updated_at desc;

		END 
	    
	
	END --- Filter date
ELSE 

	BEGIN
	         -------------No Date Filter ----------------------------------
	         Print('No Date Filter')
	         ----1. eVoucher is expired and used 
	        If (@used_status_ =1 AND Lower(LTRIM(RTRIM(@expired_status)))='yes')
			BEGIN
			
			INSERT INTO #Customer_eVoucherReport_Table (
			--evoucher_id,
			customer_id ,
			wid,
			eVoucher_code ,
			eVoucher_amount ,
			c_first_name ,
			c_last_name,
			--redeemed_winks ,
			created_at ,
			updated_at ,
			used_status ,
			expired_date ,
			branch_code,
			redeemed_on ,
			--verification_code ,
			--merchant_id ,
			--transaction_id ,
			--m_first_name ,
			--m_last_name ,
			branch_name
			--order_no
			)

				SELECT customer_earned_evouchers.customer_id,customer.WID as wid, customer_earned_evouchers.eVoucher_code,
			customer_earned_evouchers.eVoucher_amount,
			customer.first_name as c_first_name,customer.last_name as c_last_name,
			customer_earned_evouchers.created_at,customer_earned_evouchers.updated_at,
			customer_earned_evouchers.used_status,customer_earned_evouchers.expired_date,
			eVoucher_transaction.branch_code,eVoucher_transaction.created_at as redeemed_on,
			branch.branch_name
			from customer_earned_evouchers JOIN customer ON
			customer_earned_evouchers.customer_id = customer.customer_id
			LEFT JOIN eVoucher_transaction ON eVoucher_transaction.eVoucher_id = customer_earned_evouchers.earned_evoucher_id
			LEFT JOIN branch ON eVoucher_transaction.branch_code = branch.branch_code
				
				
				WHERE 
			(@customer_name is null or (Lower(customer.first_name + ' ' + customer.last_name) LIKE Lower('%'+ @customer_name +'%'))) 
			AND (@customer_id is null or customer.customer_id = @customer_id)
			AND (@wid is null or customer.WID like '%'+@wid+'%')
			AND (@branch_id is null or (lower(eVoucher_transaction.branch_code) LIKE lower('%'+ @branch_id +'%'))) 
            AND (@evoucher_code is null or (lower(customer_earned_evouchers.eVoucher_code) LIKE lower('%'+ @evoucher_code +'%')))
            and ( @branch_name is null OR branch.branch_name like '%'+@branch_name +'%')
			and	customer_earned_evouchers.used_status = 1
			and CAST(customer_earned_evouchers.expired_date as date) < CAST(@current_date as DATE)
				order by customer_earned_evouchers.updated_at desc
			END
			--2. Not selecting expird status and used status 
	       ELSE IF (@used_status ='' AND @expired_status ='')
	        BEGIN
	       
			INSERT INTO #Customer_eVoucherReport_Table (
			--evoucher_id,
			customer_id ,
			wid,
			eVoucher_code ,
			eVoucher_amount ,
			c_first_name ,
			c_last_name,
			--redeemed_winks ,
			created_at ,
			updated_at ,
			used_status ,
			expired_date ,
			branch_code,
			redeemed_on ,
			--verification_code ,
			--merchant_id ,
			--transaction_id ,
			--m_first_name ,
			--m_last_name ,
			branch_name
			--order_no
			)
			SELECT customer_earned_evouchers.customer_id,customer.WID as wid, customer_earned_evouchers.eVoucher_code,
			customer_earned_evouchers.eVoucher_amount,
			customer.first_name as c_first_name,customer.last_name as c_last_name,
			customer_earned_evouchers.created_at,customer_earned_evouchers.updated_at,
			customer_earned_evouchers.used_status,customer_earned_evouchers.expired_date,
			eVoucher_transaction.branch_code,eVoucher_transaction.created_at as redeemed_on,
			branch.branch_name
			from customer_earned_evouchers JOIN customer ON
			customer_earned_evouchers.customer_id = customer.customer_id
			LEFT JOIN eVoucher_transaction ON eVoucher_transaction.eVoucher_id = customer_earned_evouchers.earned_evoucher_id
			LEFT JOIN branch ON eVoucher_transaction.branch_code = branch.branch_code

			Where (@customer_name is null or (Lower(customer.first_name + ' ' + customer.last_name) LIKE Lower('%'+ @customer_name +'%'))) 
		AND (@customer_id is null or customer.customer_id = @customer_id)
		AND (@wid is null or customer.WID like '%'+@wid+'%')
			AND (@branch_id is null or (lower(eVoucher_transaction.branch_code) LIKE lower('%'+ @branch_id +'%'))) 
           AND (@evoucher_code is null or (lower(customer_earned_evouchers.eVoucher_code) LIKE lower('%'+ @evoucher_code +'%')))
            and ( @branch_name is null OR branch.branch_name like '%'+@branch_name +'%')

			order by customer_earned_evouchers.updated_at desc
			END
			---3.-- Expird eVoucher
		   ELSE IF(Lower(LTRIM(RTRIM(@expired_status)))='yes' AND (@used_status='' OR @used_status_=0))  
			BEGIN
	       Print('Expired Yes')
	        Print (@current_date)
			INSERT INTO #Customer_eVoucherReport_Table (
			--evoucher_id,
			customer_id ,
			wid,
			eVoucher_code ,
			eVoucher_amount ,
			c_first_name ,
			c_last_name,
			--redeemed_winks ,
			created_at ,
			updated_at ,
			used_status ,
			expired_date ,
			branch_code,
			redeemed_on ,
			--verification_code ,
			--merchant_id ,
			--transaction_id ,
			--m_first_name ,
			--m_last_name ,
			branch_name
			--order_no
			)
			SELECT customer_earned_evouchers.customer_id,customer.WID as wid, customer_earned_evouchers.eVoucher_code,
			customer_earned_evouchers.eVoucher_amount,
			customer.first_name as c_first_name,customer.last_name as c_last_name,
			customer_earned_evouchers.created_at,customer_earned_evouchers.updated_at,
			customer_earned_evouchers.used_status,customer_earned_evouchers.expired_date,
			eVoucher_transaction.branch_code,eVoucher_transaction.created_at as redeemed_on,
			branch.branch_name
			from customer_earned_evouchers JOIN customer ON
			customer_earned_evouchers.customer_id = customer.customer_id
			LEFT JOIN eVoucher_transaction ON eVoucher_transaction.eVoucher_id = customer_earned_evouchers.earned_evoucher_id
			LEFT JOIN branch ON eVoucher_transaction.branch_code = branch.branch_code
			Where 
			CAST (customer_earned_evouchers.expired_date as DATE) < Cast (@current_date as date)
			AND (@customer_name is null or (Lower(customer.first_name + ' ' + customer.last_name) LIKE Lower('%'+ @customer_name +'%'))) 
			AND (@customer_id is null or customer.customer_id = @customer_id)
			AND (@wid is null or customer.WID like '%'+@wid+'%')
			and customer_earned_evouchers.earned_evoucher_id NOT IN (select eVoucher_transaction.eVoucher_id from eVoucher_transaction)
			and customer_earned_evouchers.used_status =0
	        AND (@evoucher_code is null or (lower(customer_earned_evouchers.eVoucher_code) LIKE lower('%'+ @evoucher_code +'%')))
			order by customer_earned_evouchers.updated_at desc
			END
	
		-- 4. Not used and Not selecting expired status 
		  ELSE IF(@used_status_ =0 AND @expired_status ='') 
			BEGIN
	        Print('no datetime filter used')
			INSERT INTO #Customer_eVoucherReport_Table (
			--evoucher_id,
			customer_id ,
			wid,
			eVoucher_code ,
			eVoucher_amount ,
			c_first_name ,
			c_last_name,
			--redeemed_winks ,
			created_at ,
			updated_at ,
			used_status ,
			expired_date ,
			branch_code,
			redeemed_on ,
			--verification_code ,
			--merchant_id ,
			--transaction_id ,
			--m_first_name ,
			--m_last_name ,
			branch_name
			--order_no
			)
			SELECT customer_earned_evouchers.customer_id,customer.WID as wid, customer_earned_evouchers.eVoucher_code,
			customer_earned_evouchers.eVoucher_amount,
			customer.first_name as c_first_name,customer.last_name as c_last_name,
			customer_earned_evouchers.created_at,customer_earned_evouchers.updated_at,
			customer_earned_evouchers.used_status,customer_earned_evouchers.expired_date,
			eVoucher_transaction.branch_code,eVoucher_transaction.created_at as redeemed_on,
			branch.branch_name
			from customer_earned_evouchers JOIN customer ON
			customer_earned_evouchers.customer_id = customer.customer_id
			LEFT JOIN eVoucher_transaction ON eVoucher_transaction.eVoucher_id = customer_earned_evouchers.earned_evoucher_id
			LEFT JOIN branch ON eVoucher_transaction.branch_code = branch.branch_code

			Where (@customer_name is null or (Lower(customer.first_name + ' ' + customer.last_name) LIKE Lower('%'+ @customer_name +'%'))) 
			AND (@customer_id is null or customer.customer_id = @customer_id)
			AND (@wid is null or customer.WID like '%'+@wid+'%')
			and customer_earned_evouchers.used_status = 0
			AND (@evoucher_code is null or (lower(customer_earned_evouchers.eVoucher_code) LIKE lower('%'+ @evoucher_code +'%')))
			and ( @branch_name is null OR branch.branch_name like '%'+@branch_name +'%')
			order by customer_earned_evouchers.updated_at desc
			END
		   -- 6.. Not used and not expired
		   ELSE IF(@used_status_ =0 AND Lower(LTRIM(RTRIM(@expired_status)))='no')
			BEGIN
	        Print('no datetime filter used')
			INSERT INTO #Customer_eVoucherReport_Table (
			--evoucher_id,
			customer_id ,
			wid,
			eVoucher_code ,
			eVoucher_amount ,
			c_first_name ,
			c_last_name,
			--redeemed_winks ,
			created_at ,
			updated_at ,
			used_status ,
			expired_date ,
			branch_code,
			redeemed_on ,
			--verification_code ,
			--merchant_id ,
			--transaction_id ,
			--m_first_name ,
			--m_last_name ,
			branch_name
			--order_no
			)
			SELECT customer_earned_evouchers.customer_id,customer.WID as wid, customer_earned_evouchers.eVoucher_code,
			customer_earned_evouchers.eVoucher_amount,
			customer.first_name as c_first_name,customer.last_name as c_last_name,
			customer_earned_evouchers.created_at,customer_earned_evouchers.updated_at,
			customer_earned_evouchers.used_status,customer_earned_evouchers.expired_date,
			eVoucher_transaction.branch_code,eVoucher_transaction.created_at as redeemed_on,
			branch.branch_name
			from customer_earned_evouchers JOIN customer ON
			customer_earned_evouchers.customer_id = customer.customer_id
			LEFT JOIN eVoucher_transaction ON eVoucher_transaction.eVoucher_id = customer_earned_evouchers.earned_evoucher_id
			LEFT JOIN branch ON eVoucher_transaction.branch_code = branch.branch_code

			Where (@customer_name is null or (Lower(customer.first_name + ' ' + customer.last_name) LIKE Lower('%'+ @customer_name +'%'))) 
			AND (@customer_id is null or customer.customer_id = @customer_id)
			AND (@wid is null or customer.WID like '%'+@wid+'%')
			and customer_earned_evouchers.used_status = 0
			and CAST (customer_earned_evouchers.expired_date as DATE) >= Cast (@current_date as date)
			AND (@evoucher_code is null or (lower(customer_earned_evouchers.eVoucher_code) LIKE lower('%'+ @evoucher_code +'%')))
			and ( @branch_name is null OR branch.branch_name like '%'+@branch_name +'%')
			order by customer_earned_evouchers.updated_at desc
			END
		  -- 7. Used and Not expired or not selecting expired
		  ELSE IF(@used_status_ =1 AND (Lower(LTRIM(RTRIM(@expired_status)))='' OR Lower(LTRIM(RTRIM(@expired_status)))='no') )		
			BEGIN
	        Print('no datetime filter used')
			INSERT INTO #Customer_eVoucherReport_Table (
			--evoucher_id,
			customer_id ,
			wid,
			eVoucher_code ,
			eVoucher_amount ,
			c_first_name ,
			c_last_name,
			--redeemed_winks ,
			created_at ,
			updated_at ,
			used_status ,
			expired_date ,
			branch_code,
			redeemed_on ,
			--verification_code ,
			--merchant_id ,
			--transaction_id ,
			--m_first_name ,
			--m_last_name ,
			branch_name
			--order_no
			)
			SELECT customer_earned_evouchers.customer_id,customer.WID as wid, customer_earned_evouchers.eVoucher_code,
			customer_earned_evouchers.eVoucher_amount,
			customer.first_name as c_first_name,customer.last_name as c_last_name,
			customer_earned_evouchers.created_at,customer_earned_evouchers.updated_at,
			customer_earned_evouchers.used_status,customer_earned_evouchers.expired_date,
			eVoucher_transaction.branch_code,eVoucher_transaction.created_at as redeemed_on,
			branch.branch_name
			from customer_earned_evouchers JOIN customer ON
			customer_earned_evouchers.customer_id = customer.customer_id
			LEFT JOIN eVoucher_transaction ON eVoucher_transaction.eVoucher_id = customer_earned_evouchers.earned_evoucher_id
			LEFT JOIN branch ON eVoucher_transaction.branch_code = branch.branch_code

			Where (@customer_name is null or (Lower(customer.first_name + ' ' + customer.last_name) LIKE Lower('%'+ @customer_name +'%'))) 
			AND (@customer_id is null or customer.customer_id = @customer_id)
			AND (@wid is null or customer.WID like '%'+@wid+'%')
			and customer_earned_evouchers.used_status = 1
			AND (@branch_id is null or (lower(eVoucher_transaction.branch_code) LIKE lower('%'+ @branch_id +'%'))) 
			AND (@evoucher_code is null or (lower(customer_earned_evouchers.eVoucher_code) LIKE lower('%'+ @evoucher_code +'%')))
			and ( @branch_name is null OR branch.branch_name like '%'+@branch_name +'%')
			order by customer_earned_evouchers.updated_at desc
			END
			-- 7. Not expired And Not Used or Not selecting used status
			ELSE IF(Lower(LTRIM(RTRIM(@expired_status)))='no' AND (@used_status_ =0 OR @used_status='')) 	
			BEGIN
	        Print('No Date Filter Not Expired')
			INSERT INTO #Customer_eVoucherReport_Table (
			--evoucher_id,
			customer_id ,
			wid,
			eVoucher_code ,
			eVoucher_amount ,
			c_first_name ,
			c_last_name,
			--redeemed_winks ,
			created_at ,
			updated_at ,
			used_status ,
			expired_date ,
			branch_code,
			redeemed_on ,
			--verification_code ,
			--merchant_id ,
			--transaction_id ,
			--m_first_name ,
			--m_last_name ,
			branch_name
			--order_no
			)
			SELECT customer_earned_evouchers.customer_id,customer.WID as wid, customer_earned_evouchers.eVoucher_code,
			customer_earned_evouchers.eVoucher_amount,
			customer.first_name as c_first_name,customer.last_name as c_last_name,
			customer_earned_evouchers.created_at,customer_earned_evouchers.updated_at,
			customer_earned_evouchers.used_status,customer_earned_evouchers.expired_date,
			eVoucher_transaction.branch_code,eVoucher_transaction.created_at as redeemed_on,
			branch.branch_name
			from customer_earned_evouchers JOIN customer ON
			customer_earned_evouchers.customer_id = customer.customer_id
			LEFT JOIN eVoucher_transaction ON eVoucher_transaction.eVoucher_id = customer_earned_evouchers.earned_evoucher_id
			LEFT JOIN branch ON eVoucher_transaction.branch_code = branch.branch_code

			Where (@customer_name is null or (Lower(customer.first_name + ' ' + customer.last_name) LIKE Lower('%'+ @customer_name +'%'))) 
			AND (@customer_id is null or customer.customer_id = @customer_id)
			AND (@wid is null or customer.WID like '%'+@wid+'%')
			and customer_earned_evouchers.used_status = 0
			AND (@evoucher_code is null or (lower(customer_earned_evouchers.eVoucher_code) LIKE lower('%'+ @evoucher_code +'%')))
			and ( @branch_name is null OR branch.branch_name like '%'+@branch_name +'%')
			and 	CAST (customer_earned_evouchers.expired_date as DATE) >= Cast (@current_date as date)
			order by customer_earned_evouchers.updated_at desc
			END
			
			ELSE -- 8. Not Filter anything
			
			BEGIN
			INSERT INTO #Customer_eVoucherReport_Table (
			--evoucher_id,
			customer_id ,
			wid,
			eVoucher_code ,
			eVoucher_amount ,
			c_first_name ,
			c_last_name,
			--redeemed_winks ,
			created_at ,
			updated_at ,
			used_status ,
			expired_date ,
			branch_code,
			redeemed_on ,
			--verification_code ,
			--merchant_id ,
			--transaction_id ,
			--m_first_name ,
			--m_last_name ,
			branch_name
			--order_no
			)
			SELECT customer_earned_evouchers.customer_id,customer.WID as wid, customer_earned_evouchers.eVoucher_code,
			customer_earned_evouchers.eVoucher_amount,
			customer.first_name as c_first_name,customer.last_name as c_last_name,
			customer_earned_evouchers.created_at,customer_earned_evouchers.updated_at,
			customer_earned_evouchers.used_status,customer_earned_evouchers.expired_date,
			eVoucher_transaction.branch_code,eVoucher_transaction.created_at as redeemed_on,
			branch.branch_name
			from customer_earned_evouchers JOIN customer ON
			customer_earned_evouchers.customer_id = customer.customer_id
			LEFT JOIN eVoucher_transaction ON eVoucher_transaction.eVoucher_id = customer_earned_evouchers.earned_evoucher_id
			LEFT JOIN branch ON eVoucher_transaction.branch_code = branch.branch_code

			WHERE  
		
			(@customer_name is null or (Lower(customer.first_name + ' ' + customer.last_name) LIKE Lower('%'+ @customer_name +'%'))) 
			 AND (@customer_id is null or customer.customer_id = @customer_id)
			 AND (@wid is null or customer.WID like '%'+@wid+'%')
			AND (@branch_id is null or (lower(eVoucher_transaction.branch_code) LIKE lower('%'+ @branch_id +'%'))) 
			AND (@evoucher_code is null or (lower(customer_earned_evouchers.eVoucher_code) LIKE lower('%'+ @evoucher_code +'%')))
			and ( @branch_name is null OR branch.branch_name like '%'+@branch_name +'%')

			order by customer_earned_evouchers.updated_at desc

		END 
	    
						

		END
		
		--with duplicate as (
		--	SELECT 
		--	evoucher_code, 
		--	used_status, 
		--	COUNT(*) occurrences
		--	FROM #Customer_eVoucherReport_Table
		--	GROUP BY
		--	evoucher_code, 
		--	used_status
		--	HAVING 
		--	COUNT(*) > 1
		--)
		--Update customer set customer.status = 'disable',
		--customer.updated_at = (SELECT TODAY FROM VW_CURRENT_SG_TIME) where customer.customer_id = @customer_id;

		--IF (@@ROWCOUNT>0)
		--BEGIN
									
		--	Set @locked_reason = 'Year of birth is '+SUBSTRING(@dob, 1, 4)+'.';

		--	Insert into System_Log (customer_id, action_status,created_at,reason)
		--	Select customer.customer_id,
		--	'disable',(SELECT TODAY FROM VW_CURRENT_SG_TIME) ,@locked_reason
		--	from customer where customer.customer_id = @customer_id;

		--	-----INSERT INTO ACCOUNT FILTERING LOCK
		--	EXEC Create_WINK_Account_Filtering @customer_id,@locked_reason,@admin_user_email_for_lock_account;
		--END

		Select * from #Customer_eVoucherReport_Table
		where customer_id !=15 ---filter wink developer testing 
		order by updated_at desc; 
			-- Filter Merchant Name
	 --   IF (@merchant_name !='')
		--BEGIN
		    
		--	Select * from #Customer_eVoucherReport_Table AS report 
		--	where 
		--	customer_id !=15 and ---filter wink developer testing 
		--	Lower(report.m_first_name + ' ' + report.m_last_name) LIKE Lower('%'+ @merchant_name +'%')
		--	order by updated_at desc
			
		--END
		--ELSE 
		--BEGIN
		--	Select * from #Customer_eVoucherReport_Table
		--	where customer_id !=15  ---filter wink developer testing 
		--	order by updated_at desc
		--END

		
END



--select count(*)  from customer_earned_evouchers where used_status = 1

--select * from customer where email like '%dev@winkwink.sg%'
