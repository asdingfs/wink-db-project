
CREATE PROCEDURE [dbo].[Reset_eVoucher]
	( @eVoucher_id int ,
	  @eVoucher_code varchar(50),
	  @transaction_id varchar(50)
	)
AS
BEGIN
DECLARE @customer_id int 
DECLARE @update_count int

--1. GET eVoucher ID
--2. CHECK Transaction  
	IF @transaction_id IS NOT NULL AND @transaction_id !=''
		SET @eVoucher_id = (Select eVoucher_transaction.eVoucher_id from eVoucher_transaction where eVoucher_transaction.transaction_id = @transaction_id
		AND eVoucher_transaction.transation_status ='complete')
		
	ELSE IF @eVoucher_code IS NOT NULL AND @eVoucher_code !=''
	
		SET @eVoucher_id = (SELECT customer_earned_evouchers.earned_evoucher_id from customer_earned_evouchers where customer_earned_evouchers.eVoucher_code = @eVoucher_code)
			
	
	--2. Check Transaction 
	
	IF EXISTS (Select * from eVoucher_transaction where eVoucher_transaction.transaction_id = @transaction_id and eVoucher_transaction.transation_status= 'complete' and eVoucher_transaction.eVoucher_id = @eVoucher_id )
	
		BEGIN
			BEGIN TRANSACTION 
			
			BEGIN TRY
				--3. Update Transaction 
				   Update eVoucher_transaction set eVoucher_transaction.transation_status= 'canceled' where eVoucher_transaction.transaction_id =@transaction_id 
						and eVoucher_id = @eVoucher_id
					
					IF @@ROWCOUNT>0
						BEGIN
							SET @update_count =1;
							--4. Update eVoucher Used 
							Update customer_earned_evouchers set used_status = 0 where customer_earned_evouchers.earned_evoucher_id =@eVoucher_id
							
							IF @@ROWCOUNT >0
								BEGIN
									SET @update_count =2;
									 -- GET Customer ID	
									SET @customer_id = (Select customer_earned_evouchers.customer_id from customer_earned_evouchers where customer_earned_evouchers.earned_evoucher_id =@eVoucher_id)
									 --5. Update Customer balance
									Update customer_balance set customer_balance.total_used_evouchers= customer_balance.total_used_evouchers-1 where customer_balance.customer_id =@customer_id 
										IF @@ROWCOUNT >0
											BEGIN
												SET @update_count =3;
											END
										ELSE
											BEGIN
												ROLLBACK
												Print ('Roll BACK3')
												Select '0' as success , 'Fail to Update' as response_message
											END
								END
							ELSE
								BEGIN
									ROLLBACK
									Print ('Roll BACK2')
									Select '0' as success , 'Fail to Update Customer eVoucher ' as response_message
								
								END
						
						END
					ELSE
					
						BEGIN
						
							ROLLBACK
							Print ('Roll BACK1')
							Select '0' as success , 'Fail to Update Transaction ' as response_message
						END
						
						If @update_count =3
							BEGIN						
							--6. Commit Transaction 
							
								Commit
								Print ('Commit')
								Print ('@update_count')
								Select '1' as success , 'Successfully Updated' as response_message
							END
			
			END TRY
			
				BEGIN CATCH
				 IF @@TRANCOUNT > 0
						ROLLBACK
						 Print ('Roll BACK0')
					Select '0' as success , 'Fail to Update' as response_message
				
				END CATCH
			
			
			
			
		
		END
		
		
	ELSE 
	
		BEGIN
		
		Select '0' as success , 'Fail to Update' as response_message
		
		END
	
END
			
	
	
	
	
	
			
			
			
		
	-- Start Reset eVoucher 
	/*	BEGIN TRY
    BEGIN TRANSACTION 
		-- Update eVoucher Used Status 
        Update customer_earned_evouchers set used_status = 0 where customer_earned_evouchers.earned_evoucher_id =@eVoucher_id
			
				IF @@ROWCOUNT >0
				BEGIN
					BEGIN TRY
			    			
					IF EXISTS (Select * from eVoucher_transaction where eVoucher_transaction.transaction_id = @transaction_id and eVoucher_transaction.transation_status= 'complete' )
					BEGIN
						Update eVoucher_transaction set eVoucher_transaction.transation_status= 'canceled' where eVoucher_transaction.transaction_id =@transaction_id 
						and eVoucher_id = @eVoucher_id
							   
								IF (@@ROWCOUNT>0)
									BEGIN
									  -- GET Customer ID	
								SET @customer_id = (Select customer_earned_evouchers.customer_id from customer_earned_evouchers where customer_earned_evouchers.earned_evoucher_id =@eVoucher_id)
								
								SET @customer_id =0;
								
								Print('GET Customer ID')
								Print(@customer_id)				
								Update customer_balance set customer_balance.total_used_evouchers= customer_balance.total_used_evouchers-1 where customer_balance.customer_id =@customer_id 
									END
								ELSE
									BEGIN
									ROLLBACK
									Print ('Roll BACK1')
									Select '0' as success , 'Fail to Update' as response_message
									
									END
				    END
				     Print ('ROLL BACK 1')
					 ROLLBACK
					Select '0' as success , 'No Transaction' as response_message
				END TRY
				BEGIN CATCH
					IF @@TRANCOUNT > 0
						ROLLBACK
						 Print ('Roll BACK1')
					Select '0' as success , 'Fail to Update' as response_message
					END CATCH
				
				END 
			ELSE 
				BEGIN
				
				Print ('No Data to Reset')
				Commit
				
				Select '0' as success , 'Fail To Update' as response_message
				
				END	
				
		
	END TRY
		BEGIN CATCH
		IF @@TRANCOUNT > 0
        ROLLBACK
         Print ('Roll BACK2')
         Select '0' as success , 'Fail to Update' as response_message
		END CATCH*/
				
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
			
	


