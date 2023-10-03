CREATE  PROCEDURE [dbo].[Get_Redemption_Merchants_Report_WithFilter]
	(@start_date datetime,
	 @end_date datetime,
	 @trns_no varchar(100),
	 @merchant_name varchar(100),
	 @branch_name varchar(100),
	 @customer_email varchar(200),
	 @eVoucher varchar(100)
	 
	 )
AS
BEGIN
	
-- Without Date Time Filter    
 IF OBJECT_ID('tempdb..#Redemption_Report_Table') IS NOT NULL DROP TABLE #Redemption_Report_Table    
    
 CREATE TABLE #Redemption_Report_Table    
 (    
 transaction_id varchar(100),    
  merchant_id int,    
  customer_id int,    
  customer_name varchar(100),    
  customer_email varchar(100),    
  branch_code varchar(50),    
  created_at DateTime,    
  eVoucher_id int,    
  mas_code varchar(50) ,    
  branch_name varchar(50),
  verification_code varchar(20),
  eVoucher_code varchar(50),
  eVoucher_amount Decimal(10,2),
  first_name varchar(100),
  last_name varchar(100)   
 )    



IF (@start_date IS NOT NULL AND @end_date IS NOT NULL AND @start_date!='' AND @end_date !='')
BEGIN
		Insert Into #Redemption_Report_Table
		Select eVoucher_transaction.transaction_id,eVoucher_transaction.merchant_id,
		eVoucher_transaction.customer_id,eVoucher_transaction.customer_name,
		eVoucher_transaction.customer_email,
		eVoucher_transaction.branch_code,eVoucher_transaction.created_at,
		eVoucher_transaction.eVoucher_id,
		merchant.mas_code,branch.branch_name,eVoucher_transaction.verification_code,
		customer_earned_evouchers.eVoucher_code,
		eVoucher_transaction.eVoucher_amount,merchant.first_name,merchant.last_name
		From eVoucher_transaction,merchant,branch,customer_earned_evouchers
		Where 
		--eVoucher_verification.eVoucher_id = eVoucher_transaction.eVoucher_id 
		 eVoucher_transaction.merchant_id = merchant.merchant_id
		AND eVoucher_transaction.branch_code = branch.branch_code
		AND customer_earned_evouchers.earned_evoucher_id = eVoucher_transaction.eVoucher_id
		AND CAST(eVoucher_transaction.created_at as Date) BETWEEN @start_date AND @end_date
		order by eVoucher_transaction.ID desc
     
	

END
		----- Without Date Filter
	ELSE 
		BEGIN
			Insert Into #Redemption_Report_Table
			 Select eVoucher_transaction.transaction_id,eVoucher_transaction.merchant_id,
			 eVoucher_transaction.customer_id,eVoucher_transaction.customer_name,eVoucher_transaction.customer_email,
			 eVoucher_transaction.branch_code,eVoucher_transaction.created_at,
			 eVoucher_transaction.eVoucher_id,
			 merchant.mas_code,branch.branch_name,
			 (Select top 1 eVoucher_verification.verification_code from eVoucher_verification
			 where eVoucher_verification.eVoucher_id =eVoucher_transaction.eVoucher_id)as verification_code ,
			 customer_earned_evouchers.eVoucher_code,
			 eVoucher_transaction.eVoucher_amount,merchant.first_name,merchant.last_name
			 From eVoucher_transaction,merchant,branch,customer_earned_evouchers
			 Where 
			 --eVoucher_verification.eVoucher_id = eVoucher_transaction.eVoucher_id 
			 eVoucher_transaction.merchant_id = merchant.merchant_id
			 AND eVoucher_transaction.branch_code = branch.branch_code
			 AND customer_earned_evouchers.earned_evoucher_id = eVoucher_transaction.eVoucher_id
			 order by eVoucher_transaction.ID desc
			 --AND CAST(eVoucher_transaction.created_at as Date) BETWEEN @start_date AND @end_date
		
		END
		
		
		/*---------------Check Filter -----------------------*/
		IF (@trns_no IS NOT NULL AND @trns_no !='' AND @merchant_name IS NOT NULL AND @merchant_name !='' AND @branch_name !='' AND @branch_name IS NOT NULL AND
			@customer_email !='' AND @customer_email IS NOT NULL AND @eVoucher !='' AND @eVoucher IS NOT NULL)
				SELECT * FROM #Redemption_Report_Table AS R WHERE
				 R.transaction_id = @trns_no
				 AND lower(R.first_name + ' '+R.last_name) Like Lower('%'+@merchant_name+'%')
				 AND Lower(R.branch_name) Like Lower('%'+@branch_name+'%')
				 AND R.customer_email = @customer_email
				 AND R.eVoucher_code = @eVoucher
			--Filter with trans , merchant name , branch name ,email 
	   ELSE IF (@trns_no IS NOT NULL AND @trns_no !='' AND @merchant_name IS NOT NULL AND @merchant_name !='' AND @branch_name !='' AND @branch_name IS NOT NULL AND
			@customer_email !='' AND @customer_email IS NOT NULL)
				BEGIN
				SELECT * FROM #Redemption_Report_Table AS R WHERE
				 R.transaction_id = @trns_no
				 AND lower(R.first_name + ' '+R.last_name) Like Lower('%'+@merchant_name+'%')
				 AND Lower(R.branch_name) Like Lower('%'+@branch_name+'%')
				 AND R.customer_email = @customer_email
				 RETURN
				 END 
				
			--Filter with trans , merchant name , branch name 
	   ELSE IF (@trns_no IS NOT NULL AND @trns_no !='' AND @merchant_name IS NOT NULL AND @merchant_name !='' 
	   AND @branch_name !='' AND @branch_name IS NOT NULL )
				BEGIN
				SELECT * FROM #Redemption_Report_Table AS R WHERE
				 R.transaction_id = @trns_no
				 AND lower(R.first_name + ' '+R.last_name) Like Lower('%'+@merchant_name+'%')
				 AND Lower(R.branch_name) Like Lower('%'+@branch_name+'%')
				RETURN
				END
			--Filter with trans , merchant name , branch name ,email 
	   ELSE IF (@trns_no IS NOT NULL AND @trns_no !='' AND @merchant_name IS NOT NULL AND @merchant_name !='' AND @branch_name !='' AND @branch_name IS NOT NULL AND
			@customer_email !='' AND @customer_email IS NOT NULL)
				BEGIN
				SELECT * FROM #Redemption_Report_Table AS R WHERE
				 R.transaction_id = @trns_no
				 AND lower(R.first_name + ' '+R.last_name) Like Lower('%'+@merchant_name+'%')
				 AND Lower(R.branch_name) Like Lower('%'+@branch_name+'%')
				 AND R.customer_email = @customer_email
				 RETURN
				 END 
				 
				 --Filter with trans , merchant name 
		ELSE IF (@trns_no IS NOT NULL AND @trns_no !='' AND @merchant_name IS NOT NULL AND @merchant_name !='' )
				BEGIN
				SELECT * FROM #Redemption_Report_Table AS R WHERE
				 R.transaction_id = @trns_no
				 AND lower(R.first_name + ' '+R.last_name) Like Lower('%'+@merchant_name+'%')
				 RETURN
				 END
		--Filter with Trans no and branch name 
		ELSE IF (@trns_no IS NOT NULL AND @trns_no !='' AND @branch_name !='' AND @branch_name IS NOT NULL )
	   
				BEGIN
				SELECT * FROM #Redemption_Report_Table AS R WHERE
				 R.transaction_id = @trns_no
				-- AND lower(R.first_name + ' '+R.last_name) Like Lower('%'+@merchant_name+'%')
				 AND Lower(R.branch_name) Like Lower('%'+@branch_name+'%')
				RETURN
				END
		
		 --Filter with trans
		ELSE IF (@trns_no IS NOT NULL AND @trns_no !='')
				BEGIN
				print('bb')
				SELECT * FROM #Redemption_Report_Table AS R WHERE
				 R.transaction_id = @trns_no
				RETURN
				END
			
				
	     ELSE
				BEGIN
				print('aa')
				SELECT * FROM #Redemption_Report_Table 
				RETURN
				END
--select * from eVoucher_transaction order by eVoucher_transaction.ID desc

END