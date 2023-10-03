
CREATE PROCEDURE  [dbo].[Update_WINK_Account_Filtering_New] 
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
	@multiple_account_id varchar(10),
	@Customer_clarification varchar(1000),
	@End_suspension_date varchar(20),
	@Ops_manager_recommendation varchar(255),
	
	/*@ops_staff_action_status varchar(100),*/
	@dev_team_action_status varchar(100),
	@ops_manager_action_status varchar(100),
	@Final_approval_status varchar (100),
	@Final_approval_remark varchar(1000)
	--@whatspp_matching_status varchar(30)
	)
AS
BEGIN 
DECLARE @current_date datetime

DECLARE @maxID int
DECLARE	@action_role_id int,
		@admin_name varchar(100)




DECLARE 
	@old_offender_status varchar(10),
    @old_whatsapp_phone_no varchar(10) ,
	@old_whatsapp_received_date varchar(20) ,
	@old_email_request_status varchar(10) ,
	@old_whatsapp_request_status varchar(10) ,
	
	@old_reason varchar(2000) ,
	@old_confiscated_status varchar(10) ,
	@old_confiscated_date varchar(20),
	@old_confiscation_batch varchar(50) ,
	@old_filtering_status varchar(50) ,
	@old_unlocked_date datetime ,
	@old_remark varchar(2000),
	@old_enquiry_received_date varchar(50),
	@old_Dev_team_name varchar(100),
    @old_Dev_team_action_date varchar(20),
	@old_Ops_staff_name varchar(100),
    @old_Ops_staff_action_date varchar(20),
	@old_Ops_manager_name varchar(100),
    @old_Ops_manager_action_date varchar(20),
	@old_email_received_date varchar(20),
	@old_final_approval_action_date varchar(20),
	@old_final_approval_action_name varchar(50),
	@old_Locked_reason_updated_date varchar(20),
	@old_Final_approval_remark varchar(255),
	@old_Final_approval_status varchar(100),
	@old_dev_team_action_status varchar(100),
	@old_ops_staff_action_status varchar(100),
	@old_ops_manager_action_status varchar(100)
	

		  
	if(@filtering_status ='default')
	set @filtering_status = @old_filtering_status

	

	select
	
	@old_whatsapp_phone_no = whatsapp_phone_no,
	@old_offender_status=[offender_status],
	@old_whatsapp_received_date = whatsapp_received_date,
	@old_email_request_status = email_request_status,
	@old_whatsapp_request_status = whatsapp_request_status,
	@old_reason = reason,
	@old_confiscated_status = confiscated_status,
	@old_confiscation_batch = confiscation_batch,
	@old_confiscated_date = confiscated_date,
	@old_filtering_status = filtering_status,
	@old_unlocked_date = unlocked_date,
	@old_remark = remark,
	@old_enquiry_received_date =enquiry_received_date
	,@old_Dev_team_name = Dev_team_name
	,@old_Dev_team_action_date = Dev_team_action_date
	,@old_Ops_manager_action_date = Ops_manager_action_date
	,@old_Ops_manager_name = Ops_manager_name
	,@old_Ops_staff_action_date = Ops_staff_action_date
	,@old_Ops_staff_name = Ops_staff_name
	,@old_email_received_date = email_received_date
	,@old_final_approval_action_date = Final_approval_action_date
	,@old_final_approval_action_name = Final_approval_name
	,@old_Final_approval_remark = Final_approval_remark
	,@old_Locked_reason_updated_date = Locked_reason_updated_at
	,@old_dev_team_action_status =dev_team_action_status
	,@old_ops_staff_action_status = ops_staff_action_status
	,@old_ops_manager_action_status = ops_manager_action_status
	
	from wink_account_filtering
	where id = @account_filtering_id	 
	
	


	EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date output

	-------------1. GET THE ACTION USER ROLE 
		SET @action_role_id =0
		SELECT @action_role_id = admin_role_id, @admin_name = (admin_user.first_name+' '+ admin_user.last_name) from admin_user where email =@admin_user_email
		----- 1.2 ----UPDATE ACTION DATE BY ROLE 

		if(@action_role_id >0)
		BEGIN
			---- GET INTERNAL PROCEDURE ID 
			DECLARE @internal_procedure int 

			SET @internal_procedure = ISNULL ((select internal_procedure from wink_account_filtering_status_new 
			where filtering_status = @filtering_status),0)

					---OPS ACTION
					IF(@action_role_id =4 OR @action_role_id = 9)
								BEGIN
									----FIRST FRIST PROCEDURE UPDATE By Ops
									IF ( (@dev_team_action_status is null OR @dev_team_action_status = '' OR
									    @dev_team_action_status = 'pending_further_clarification' ) and @internal_procedure =1)
									BEGIN
									    
										SET @old_Ops_staff_name = @admin_name
										SET @old_Ops_staff_action_date = @current_date

									END
									ELSE IF ((@dev_team_action_status is not null and @dev_team_action_status != ''
									and @dev_team_action_status ='sop' ) and @internal_procedure =3)-----THIRD PROCEDURE UPDATE By Ops
									
									BEGIN
									    IF EXISTS (SELECT 1 from wink_account_filtering_status_new where filtering_status_key  = @filtering_status
										and internal_procedure = 3)
										BEGIN
										SET @old_Ops_manager_name = @admin_name
										SET @old_Ops_manager_action_date = @current_date
										SET @ops_manager_action_status = @filtering_status
										END

										

									END

								END
					ELSE IF (@action_role_id =1) --- DEV UPDATE 
							BEGIN
							IF (@filtering_status='pending_remark' and @internal_procedure = 2) --- SECOND PROCEDURE UPDATE BY DEV
								BEGIN
								SET @old_Dev_team_name = @admin_name
								SET @old_Dev_team_action_date = @current_date

								END
							

							END

		END


		  ------2.------SET DEFAULT VALUE 

				---2.1. CURRENT DATE
					EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date OUTPUT
				---2.2. DEFAULT WHATSAPP STATUS 
					SET @whatsapp_request_status ='No'
				---2.3. Filtering Status
					IF(@filtering_status ='default')
					SET @filtering_status = @old_filtering_status
				---2.4. Lock Reason
					IF (@old_reason is null or @old_reason ='')
						IF (@reason is not null and @reason !='')
							BEGIN
							SET @old_Locked_reason_updated_date = @current_date
							END
				

		------END SET DEFAULT VALUE ---------


		----3.-----UPDATE ACCOUNT FILTERING STATUS FROM ACCOUNT FILTERING DETAIL

			IF (@from_customer_detail ='No')
				BEGIN
				
					print('From account filtering')

					--- CHECK THE ACCOUNT MUST BE LOCKED
					IF EXISTS (SELECT 1 FROM customer WHERE customer_id = @customer_id and status ='enable')
					BEGIN
					RETURN 0

					END
					
					
					---3.1. FIRST TIME ENQUIRY STATUS UPDATE 

						IF (@email_request_status ='Yes' and @old_email_request_status ='No')
							BEGIN
								
								set @old_email_received_date = @current_date

							END

					
					---3.2 Whatsapp Status 	
					  IF (@whatsapp_phone_no is not null and @whatsapp_phone_no !='')
					  BEGIN

						SET @whatsapp_request_status = 'Yes'
						
					  END
					
					---3.3 -- CHECK MULTIPLE ACCOUNT BY WHATSAPP PHONE NO.--------
					  IF EXISTS (SELECT 1 FROM CUSTOMER WHERE CUSTOMER_ID = @multiple_account_id AND status ='enable')
						  IF NOT EXISTS (SELECT 1 FROM wink_account_filtering WHERE filtering_status !='done' and customer_id =@multiple_account_id)
							BEGIN
								---- lock account and insert 
								update customer set status ='disable' where customer.customer_id =@multiple_account_id
					  
								declare @lock_reason varchar(255)
								set @lock_reason = Concat ('ID',@customer_id,' send in Whatsapp with phone no. of ID',@multiple_account_id)
								SET @admin_user_email ='system@winkwink.sg'
					  
								--EXEC Create_WINK_Account_Filtering @multiple_account_id,Concat('Multiple Account Of ',@customer_id), 
								EXEC Create_WINK_Account_Filtering @multiple_account_id,@lock_reason,@admin_user_email
							END
					 
					  ---3.4-------- CONFISCATION POINTS AND WINKS
					  Declare @confiscate_and_unlock int 

					  SET @confiscate_and_unlock =0
					   ---Confiscation and Unlock-----

					  IF( (@filtering_status ='confiscation_and_unlock_approve' OR 
					  
					  @filtering_status ='confiscation_and_1MS_approve'
					  OR @filtering_status ='confiscation_and_3M_s_approve'
					  OR @filtering_status ='confiscation_and_permanent_s_approve')
					  
					  
					  )
					  
					  BEGIN							
							IF EXISTS (select 1 from [wink_account_filtering] where (id = @account_filtering_id)
							AND ( ops_manager_action_status ='confiscation_and_unlock' OR 
							ops_manager_action_status ='confiscation_and_1MS' OR 
							ops_manager_action_status ='confiscation_and_3M_s' OR 
							ops_manager_action_status ='confiscation_and_permanent_s' and confiscated_status !='Done'))
							
							BEGIN
								SET @old_final_approval_action_name = @admin_name
								SET @old_final_approval_action_date = @current_date

								SET @Final_approval_status = @filtering_status 

								EXEC Points_Confiscated @customer_id
								EXEC WINK_Confiscated @customer_id
								-----SUCCESSFULLY CONFISCATED
								IF( ISNULL((select sum(total_winks-used_winks-confiscated_winks) from customer_balance
								where customer_id = @customer_id
								),0) =0)
								BEGIN
									
									SET @old_confiscated_status ='Done'
									
									SET @old_confiscated_date =@current_date 

									IF (@Final_approval_status = 'confiscation_and_unlock_approve')
									BEGIN
									SET @confiscate_and_unlock = 1

									END

								        ----- Suspension
										IF(@End_suspension_date is not null and @End_suspension_date !='')
											BEGIN
												IF (@Final_approval_status = 'confiscation_and_1MS_approve')
												BEGIN
									
												SET @old_unlocked_date = DATEADD (Month,1,@current_date)
									            
												END
												ELSE IF (@Final_approval_status = 'confiscation_and_3M_s_approve')
												BEGIN
									
												SET @old_unlocked_date = DATEADD (Month,1,@current_date)
									
												END

												SET @End_suspension_date = @old_unlocked_date
											END
									-----PERMENANT SUSPENSION
									      IF (@Final_approval_status = 'confiscation_and_permanent_s')
												BEGIN
									
												SET @filtering_status = 'done'
									            
												END


								END
							END

							

					  END
		  
			  ----UNLOCKED THE ACCOUNT
			  IF (@filtering_status ='no_panelty_unlocking_approved' OR @confiscate_and_unlock =1 OR @filtering_status ='unlock')
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
						SET @old_unlocked_date =@current_date
						SET @filtering_status ='done'
						END

					END

					

			  END


			  UPDATE [dbo].[wink_account_filtering]
			   SET [whatsapp_phone_no] =@old_whatsapp_phone_no
   
				  ,[whatsapp_received_date] = @whatsapp_phone_no
				  ,[email_request_status] = @email_request_status
				  ,[whatsapp_request_status] = @whatsapp_request_status
				  ,[reason] = @reason
				  ,[confiscated_status] = @old_confiscated_status
				  ,[confiscation_batch] = @old_confiscation_batch
				  ,[filtering_status] = @filtering_status
				  ,[unlocked_date] = @old_unlocked_date
				  ,[remark] = @remark
     
				  ,[updated_at] = @current_date
				  ,[enquiry_received_date] = @old_enquiry_received_date
				  ,[confiscated_date] = @old_confiscated_date
				  ,[multiple_account_id] = @multiple_account_id
      
				  ,[Dev_team_name] = @old_Dev_team_name
				  ,[Dev_team_action_date] = @old_Dev_team_action_date
				  ,[Ops_manager_action_date] = @old_Ops_manager_action_date
				  ,[Ops_manager_name] = @old_Ops_manager_name
				  ,[Ops_staff_action_date] = @old_Ops_staff_action_date
				  ,[Ops_staff_name] = @old_Ops_staff_name
				  ,[Customer_clarification] = @Customer_clarification
				  ,[End_suspension_date] = @End_suspension_date
				  ,[Ops_manager_recommendation] = @Ops_manager_recommendation
				  ,[email_received_date] = @old_email_received_date
				  ,[Final_approval_action_date] = @old_final_approval_action_date
				  ,[Final_approval_name] = @old_final_approval_action_name
				  ,[Final_approval_remark] =@old_Final_approval_remark
				  ,[Final_approval_status] = @Final_approval_status
				  ,[Locked_reason_updated_at] = @old_Locked_reason_updated_date
				  ,dev_team_action_status =@dev_team_action_status
				  ,ops_manager_action_status = @ops_manager_action_status
				   WHERE id = @account_filtering_id
		 		
				
			
				------START LOG
			/*	IF(@@ROWCOUNT>0) 
				
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
					@old_diasbled_date  ,
					@whatsapp_received_date  ,
					@email_request_status  ,
					@whatsapp_request_status  ,
					@old_offender_status  ,
					@reason  ,
					@confiscated_status ,
					@old_confiscation_batch  ,
					@filtering_status  ,
					@old_unlocked_date  ,
					@remark  ,
					@admin_user_email ,
					'AccountFiltering' ,
					'Edit',
					@account_filtering_id ,
					@old_enquiry_received_date ,

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
*/

							
	/*if(@result=2)
	BEGIN
	/*Delete from campaign where campaign.campaign_id =@campaign_id
	SET @campaign_id=0*/
	END*/


		END
		---UPDATE ACCOUNT FITLERING FOR UPDATE STATUS FROM CUSTOEMR TAB
		ELSE IF(@from_customer_detail ='Yes')
		BEGIN
		
		---1.1 UNLOCK THE ACCOUNT FROM CUSTOMER TAB
			IF (@unlocked_status ='Yes' and @from_customer_detail ='Yes')
				BEGIN
				--- GET THE LATEST ID OF THE ACCOUNT FILTER BY CUSTOMER ID
				
					SELECT  @account_filtering_id = max(ID) FROM wink_account_filtering WHERE Customer_id = @customer_id 
					and filtering_status != 'Done'

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
							--- CHECK 
							IF NOT EXISTS (select 1 from customer_earned_evouchers where customer_id =
							@customer_id and cast(created_at as date) < cast(@current_date as date))
							BEGIN
									UPDATE [wink_account_filtering] SET  confiscated_status= @confiscated_status
								   , updated_at = @current_date
									WHERE ID = @account_filtering_id
							END
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

		END


		
	




END




