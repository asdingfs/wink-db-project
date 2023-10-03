
CREATE PROCEDURE  [dbo].[Update_WINK_Account_Filtering] 
(
    @customer_id int ,
	@whatsapp_phone_no varchar(10) ,
	@email_request_status varchar(10) ,
	@whatsapp_request_status varchar(10),
	@reason varchar(2000) ,
	@remark varchar(2000) ,
	@admin_user_email varchar(100),
	@filtering_status varchar(100),
	@confiscated_status varchar(10),
	@account_filtering_id int ,
	@whatsapp_received_date varchar(30) ,
	--@unlocked_date datetime,
	@unlocked_status varchar(10),
	@from_customer_detail varchar(10),
	@multiple_account_id varchar(10)
	--@whatspp_matching_status varchar(30)
	)
AS
BEGIN 
DECLARE @current_date datetime


DECLARE @maxID int
DECLARE @registered_email varchar(100) ,
		@WINKs_in_eWallet decimal(10, 2) ,
		@points_in_eWallet decimal(10, 2) ,
		@last_expired_evoucher datetime ,
		@registered_phone_no varchar(10) ,
		@offender_status varchar(50),
		@diasbled_date datetime ,
		
	    @confiscation_batch varchar(50) ,
		@unlocked_date datetime,
		@enquiry_received_date datetime,
		@confiscated_date varchar(25)
		

DECLARE @old_whatsapp_phone_no varchar(10) ,
	@old_diasbled_date datetime ,
	@old_whatsapp_received_date varchar(20) ,
	@old_email_request_status varchar(10) ,
	@old_whatsapp_request_status varchar(10) ,
	
	@old_reason varchar(2000) ,
	@old_confiscated_status varchar(10) ,
	@old_confiscation_batch varchar(50) ,
	@old_filtering_status varchar(50) ,
	@old_unlocked_date datetime ,
	@old_remark varchar(2000),
	@old_enquiry_received_date varchar(50) 


	select
	
	@registered_email=[registered_email],
	 @WINKs_in_eWallet=[WINKs_in_eWallet],
	 @points_in_eWallet=[points_in_eWallet],
	  @last_expired_evoucher= [last_expired_evoucher],
	   @registered_phone_no=[registered_phone_no],

	 @old_whatsapp_phone_no = whatsapp_phone_no,
	 @offender_status=[offender_status],
	 @diasbled_date=[diasbled_date],
	@old_diasbled_date = diasbled_date,
	@old_whatsapp_received_date = whatsapp_received_date,
	@old_email_request_status = email_request_status,
	@old_whatsapp_request_status = whatsapp_request_status,
	@old_reason = reason,
	@old_confiscated_status = confiscated_status,
	@old_confiscation_batch = confiscation_batch,
	@old_filtering_status = filtering_status,
	@old_unlocked_date = unlocked_date,
	@old_remark = remark,
	@old_enquiry_received_date =enquiry_received_date
	from wink_account_filtering
	where id = @account_filtering_id	 
	
	
	SET @enquiry_received_date = @old_enquiry_received_date
	  

		--SET @offender_status = 1
		--- SET CURRENT DATE
		EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date OUTPUT
		---SET DISABLED DATE 
		SET @diasbled_date = @current_date


		---SET DEFAULT WHATSAPP STATUS 
		SET @whatsapp_request_status ='No'

		Print ('4')
	
	---1. UPDATE ACCOUNT FITLERING FOR UPDATE STATUS FROM CUSTOEMR TAB

		---1.1 UNLOCK THE ACCOUNT FROM CUSTOMER TAB
			IF (@unlocked_status ='Yes' and @from_customer_detail ='Yes')
				BEGIN
				--- GET THE LATEST ID OF THE ACCOUNT FILTER BY CUSTOMER ID
				
				SELECT  @account_filtering_id = max(ID) FROM wink_account_filtering WHERE Customer_id = @customer_id and filtering_status != 'Done'
				IF( @account_filtering_id !=0)
					BEGIN
						IF EXISTS (select 1 from customer where customer_id = @customer_id and status ='enable')
						BEGIN
						UPDATE [wink_account_filtering] SET  unlocked_date= @current_date,
						filtering_status ='Done'
						, updated_at = @current_date
						WHERE ID = @account_filtering_id
						END
					END

					

				END 



			--1.2 CONFISCATION DONE STATUS FROM CUSTOMER TAB

			ELSE IF(@confiscated_status ='Done' and @from_customer_detail ='Yes')
				BEGIN
					SELECT  @account_filtering_id = max(ID) FROM wink_account_filtering WHERE Customer_id = @customer_id and filtering_status != 'Done'
					IF( @account_filtering_id !=0)
					BEGIN
						IF EXISTS (select 1 from customer where customer_id = @customer_id and status ='disable')
						BEGIN
							UPDATE [wink_account_filtering] SET  confiscated_status= @confiscated_status
				           , updated_at = @current_date
							WHERE ID = @account_filtering_id
						END
					END

				END 

			---1.3 UPDATE REASON FROM CUSTOMER DETAIL
			ELSE IF(@reason !='' and @from_customer_detail ='Yes')
				BEGIN

				Print ('1.3 UPDATE REASON FROM CUSTOMER DETAIL')

				SELECT  @account_filtering_id = max(ID) FROM wink_account_filtering WHERE Customer_id = @customer_id

				UPDATE [wink_account_filtering] SET  reason = @reason , updated_at = @current_date
				
				WHERE ID = @account_filtering_id

				END 

				
			

			--2.4 UPDATE FROM THE ACCOUNT FILTERING PROCESS--------------------------------
			ELSE IF( @from_customer_detail ='No')
				BEGIN
				Print ('1111111')
					--- CHECK THE ACCOUNT MUST BE LOCKED
					IF EXISTS (SELECT 1 FROM customer WHERE customer_id = @customer_id and status ='enable')
					BEGIN
					RETURN 0

					END



					----FILTERING STATUS 
					---1. FIRST TIME ENQUIRY STATUS UPDATE 

					IF EXISTS (SELECT 1 FROM [wink_account_filtering] WHERE CUSTOMER_ID = @customer_id
					AND email_request_status ='No' and @email_request_status ='Yes' and @whatsapp_phone_no ='')
					BEGIN
					set @enquiry_received_date = @current_date
					set @filtering_status ='pending_whatsapp'

					END
					
					
			Print ('5')
					 
				
					  IF (@whatsapp_phone_no is not null and @whatsapp_phone_no !='')
					  BEGIN
						SET @whatsapp_request_status = 'Yes'
						--SET @whatsapp_received_date = @current_date
					  END

					  ---AUTO UPDATE REMARK
					  IF(@filtering_status ='Confiscation_Suspension_Recommend' or 
					  @filtering_status ='confiscation_recommend' or @filtering_status ='approved' OR @filtering_status='onhold' or @filtering_status='pending_clarification' )
					  BEGIN
						IF EXISTS (select 1 from [wink_account_filtering] where id = @account_filtering_id
						and remark ='')
						BEGIN
							---- Check Edward Remark first 
							IF (@remark is null OR @remark ='')
								BEGIN
								Select @remark = filtering_status_name from wink_account_filtering_status where 
								filtering_status_key = @filtering_status
								END
						END

						IF (@filtering_status ='Confiscation_Suspension_Recommend' OR @filtering_status ='confiscation_recommend')
						SET @confiscated_status ='Pending'

					  END

Print ('6')
			
					  ----OPS CONFISCATION POINTS AND WINKS
					  Declare @confiscate_and_unlock int 
					  IF(@filtering_status ='confiscation_only' OR @filtering_status ='confiscation_and_suspension' )
					  
					  BEGIN
							
							

							IF EXISTS (select 1 from [wink_account_filtering] where id = @account_filtering_id
							and confiscated_status !='done')
							BEGIN
								EXEC Points_Confiscated @customer_id
								EXEC WINK_Confiscated @customer_id

								IF( ISNULL((select sum(total_winks-used_winks-confiscated_winks) from customer_balance
								where customer_id = @customer_id
								),0) =0)
								BEGIN
									SET @confiscated_status ='Done'

									IF (@filtering_status='confiscation_only')
									SET @confiscate_and_unlock = 1
									SET @confiscated_date =@current_date


								END
							END

							

					  END
Print ('7')
			  
			  ----UNLOCKED THE ACCOUNT
			  IF (@filtering_status ='approved' OR @confiscate_and_unlock =1)
			  BEGIN
				----1. UNLOCKED THE ACCOUNT IMMEDIATELY
				 SELECT @customer_id = CUSTOMER_ID FROM [wink_account_filtering]  
				 WHERE id = @account_filtering_id AND (unlocked_date ='' OR unlocked_date IS NULL)

				 ----2. CHECK ACCOUNT IS DISABLE ?
				 IF EXISTS (SELECT 1 FROM CUSTOMER WHERE CUSTOMER.customer_id = @customer_id AND 
				 status = 'disable')
					BEGIN
				    ----3.UNLOCKED THE ACCOUNT 
					UPDATE CUSTOMER SET status ='enable'  WHERE CUSTOMER.customer_id = @customer_id
					and status = 'disable'

				    IF(@@ROWCOUNT>0)
						BEGIN
						SET @unlocked_date =@current_date
						SET @filtering_status ='done'
						END

					END

					

			  END

			  Print ('6')

			  ---- CHECK MULTIPLE ACCOUNT LOCK CONDITION AND LOCK IT 
			  IF EXISTS (SELECT 1 FROM CUSTOMER WHERE CUSTOMER_ID = @multiple_account_id AND status ='enable')
			  IF NOT EXISTS (SELECT 1 FROM wink_account_filtering WHERE filtering_status !='done' and customer_id =@multiple_account_id)
			  BEGIN
			  ---- lock account and insert 
			  update customer set status ='disable' where customer.customer_id =@multiple_account_id
			  declare @lock_reason varchar(255)
			  set @lock_reason = Concat ('ID',@customer_id,' send in Whatsapp with phone no. of ID',@multiple_account_id)
			  --EXEC Create_WINK_Account_Filtering @multiple_account_id,Concat('Multiple Account Of ',@customer_id), 
			  EXEC Create_WINK_Account_Filtering @multiple_account_id,@lock_reason,@admin_user_email
			  END



				-----UPDATE ACCOUNT FILTERING STATUS 
				UPDATE [wink_account_filtering] SET [whatsapp_phone_no] = @whatsapp_phone_no,
				[whatsapp_received_date] = @whatsapp_received_date,
				[email_request_status] =@email_request_status,
				whatsapp_request_status = @whatsapp_request_status,
				reason= @reason,
				remark = @remark,
				updated_at = @current_date,
				filtering_status = @filtering_status,
				unlocked_date =@unlocked_date,
				enquiry_received_date= @enquiry_received_date,
				confiscated_status = @confiscated_status,
				confiscated_date = @confiscated_date
				
				,multiple_account_id = @multiple_account_id
				
				WHERE id = @account_filtering_id
				

				------START LOG
				IF(@@ROWCOUNT>0) 
				
				BEGIN
					Print ('kk')
				 Declare @result int
			--- Call Campaign Log Storeprocedure Function 

					EXEC Create_WINK_Account_Filtering_Log
					@result  output,
					@customer_id  ,
					@registered_email  ,
					@WINKs_in_eWallet  ,
					@points_in_eWallet  ,
					@last_expired_evoucher  ,
					@registered_phone_no ,
					@whatsapp_phone_no  ,
					@diasbled_date  ,
					@whatsapp_received_date  ,
					@email_request_status  ,
					@whatsapp_request_status  ,
					@offender_status  ,
					@reason  ,
					@confiscated_status ,
					@confiscation_batch  ,
					@filtering_status  ,
					@unlocked_date  ,
					@remark  ,
					@admin_user_email ,
					'AccountFiltering' ,
					'Edit',
					@account_filtering_id ,
					@enquiry_received_date ,

					@old_whatsapp_phone_no ,
					@old_diasbled_date  ,
					@old_whatsapp_received_date  ,
					@old_email_request_status  ,
					@old_whatsapp_request_status ,
					@old_reason  ,
					@old_confiscated_status  ,
					@old_confiscation_batch ,
					@old_filtering_status  ,
					@old_unlocked_date  ,
					@old_remark ,
					@old_enquiry_received_date ;
					
					/*IF(@@ROWCOUNT>0)
				Return 1*/

					Return @result

				END


							
	/*if(@result=2)
	BEGIN
	/*Delete from campaign where campaign.campaign_id =@campaign_id
	SET @campaign_id=0*/
	END*/


		END



END

