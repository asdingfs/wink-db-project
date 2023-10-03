CREATE PROCEDURE  [dbo].[Create_WINK_Account_Filtering_Log] 
(
    @result int out,
    @customer_id int ,
	@registered_email varchar(100) ,
	@WINKs_in_eWallet decimal(10, 2) ,
	@points_in_eWallet decimal(10, 2) ,
	@last_expired_evoucher datetime ,
	@registered_phone_no varchar(10) ,
	@whatsapp_phone_no varchar(10) ,
	@diasbled_date datetime ,
	@whatsapp_received_date varchar(40) ,
	@email_request_status varchar(10) ,
	@whatsapp_request_status varchar(10) ,
	@offender_status varchar(50) ,
	@reason varchar(2000) ,
	@confiscated_status varchar(10) ,
	@confiscation_batch varchar(50) ,
	@filtering_status varchar(50) ,
	@unlocked_date datetime ,
	@remark varchar(2000) ,
	@admin_email varchar(100),
	@action_object VARCHAR (50),
	@action_type VARCHAR(20),
	@account_filtering_id int,
	@enquiry_received_date varchar(50),

	

	@old_whatsapp_phone_no varchar(10) ,
	@old_diasbled_date datetime ,
	@old_whatsapp_received_date varchar(40) ,
	@old_email_request_status varchar(10) ,
	@old_whatsapp_request_status varchar(10) ,
	
	@old_reason varchar(2000) ,
	@old_confiscated_status varchar(10) ,
	@old_confiscation_batch varchar(50) ,
	@old_filtering_status varchar(50) ,
	@old_unlocked_date datetime ,
	@old_remark varchar(2000),
	@old_enquiry_received_date varchar(50) 
	
)
AS
BEGIN 
DECLARE @current_date datetime
DECLARE @maxID int
DECLARE @user_id_tmp int
DECLARE @log_id int
DECLARE @admin_username VARCHAR(50)
DECLARE @action_id int
DECLARE @link_url VARCHAR (100)

EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date

		BEGIN TRY
			if(@account_filtering_id is not null and @account_filtering_id !=0 and @admin_email !='' and @admin_email is not null)

			BEGIN
			-- GET LOG ID
				Set @log_id = (select top 1 admin_log.id from admin_log where admin_log.user_id = (select admin_user.admin_user_id from admin_user where admin_user.email = @admin_email) 
							 order by admin_log.id desc)
                select @admin_username = (admin_user.first_name+' '+ admin_user.last_name) from admin_user where admin_user.email = @admin_email

			-- UPDATE USER COUNT

	           update admin_log set action_count = ISNULL(action_count,0)+1 where admin_log.id =@log_id



			-- CHECK ACTION TYPE
			--- EDIT ACTION 
			if(@action_type ='Edit')
					Begin
					-- SET Link_url 
						Set @link_url = 'adminactiondetail/accountfilteringediteddetail'
					-- Add Action 
						insert into action_log
						(log_id,action_object,action_table_name,
						action_time,action_type,admin_user_email,admin_user_name,link_url)
						values (@log_id,'Account_Filtering','account_filtering_log',
						@current_date,@action_type,@admin_email,@admin_username,@link_url)
	
						-- Get Action ID

						Set @action_id = (select top 1 action_id from action_log where action_log.admin_user_email = @admin_email order by action_id desc)
						
						 -- Add Old Data Log before modify
						INSERT INTO [dbo].[wink_account_filtering_olddata_log]
							   (
								action_id ,
								[customer_id]
							   ,[old_registered_email]
							   ,[old_WINKs_in_eWallet]
							   ,[old_points_in_eWallet]
							   ,[old_last_expired_evoucher]
							   ,[old_registered_phone_no]
							   ,[old_whatsapp_phone_no]
							   ,[old_diasbled_date]
							   ,[old_whatsapp_received_date]
							   ,[old_email_request_status]
							   ,[old_whatsapp_request_status]
							   ,[old_offender_status]
							   ,[old_reason]
							   ,[old_confiscated_status]
							   ,[old_confiscation_batch]
							   ,[old_filtering_status]
							   ,[old_unlocked_date]
							   ,[old_remark]
							   ,created_at
							  -- ,old_account_filtering_id 
							   ,enquiry_received_date
							   )
					 select @action_id,[customer_id],[registered_email],
					 [WINKs_in_eWallet],[points_in_eWallet],[last_expired_evoucher],
					 [registered_phone_no],@old_whatsapp_phone_no,
					 
					 [diasbled_date],@old_whatsapp_received_date,
					 
					 @old_email_request_status, @old_whatsapp_request_status,
					 [offender_status]
					
							   ,@old_reason
							   ,@old_confiscated_status
							   ,@old_confiscation_batch
							   ,@old_filtering_status
							   ,@old_unlocked_date
							   ,@old_remark
							   ,@current_date
							  -- ,@account_filtering_id 
							   ,enquiry_received_date
					 
					  FROM wink_account_filtering
					 WHERE id = @account_filtering_id

						 -- Add New Data Log 

						 INSERT INTO [dbo].[wink_account_filtering_newdata_log]
							   (
								action_id ,
								[customer_id]
							   ,[registered_email]
							   ,[WINKs_in_eWallet]
							   ,[points_in_eWallet]
							   ,[last_expired_evoucher]
							   ,[registered_phone_no]
							   ,[whatsapp_phone_no]
							   ,[diasbled_date]
							   ,[whatsapp_received_date]
							   ,[email_request_status]
							   ,[whatsapp_request_status]
							   ,[offender_status]
							   ,[reason]
							   ,[confiscated_status]
							   ,[confiscation_batch]
							   ,[filtering_status]
							   ,[unlocked_date]
							   ,[remark]
							   ,created_at
							   --,account_filtering_id 
							   ,enquiry_received_date
							   )
					 SELECT     @action_id ,
								[customer_id]
							   ,[registered_email]
							   ,[WINKs_in_eWallet]
							   ,[points_in_eWallet]
							   ,[last_expired_evoucher]
							   ,[registered_phone_no]
							   ,[whatsapp_phone_no]
							   ,[diasbled_date]
							   ,[whatsapp_received_date]
							   ,[email_request_status]
							   ,[whatsapp_request_status]
							   ,[offender_status]
							   ,[reason]
							   ,[confiscated_status]
							   ,[confiscation_batch]
							   ,[filtering_status]
							   ,[unlocked_date]
							   ,[remark]
							   ,@current_date
							  -- ,@account_filtering_id 
							   ,enquiry_received_date

							   FROM wink_account_filtering
					 WHERE id = @account_filtering_id

										END
				    
					ELSE
					BEGIN
					-- SET Link_url 
						Set @link_url = 'adminactiondetail/accountfilteringdetail'
					-- Add Action 
						insert into action_log
						(log_id,action_object,action_table_name,
						action_time,action_type,admin_user_email,admin_user_name,link_url)
						values (@log_id,'Account_Filtering','account_filtering_log',
						@current_date,@action_type,@admin_email,@admin_username,@link_url)
	
						-- Get Action ID

						Set @action_id = (select top 1 action_id from action_log where action_log.admin_user_email = @admin_email order by action_id desc)
						
					
						 -- Add New Data Log 

						 INSERT INTO [dbo].[wink_account_filtering_olddata_log]
							   ([action_id]
									,[customer_id]
							   ,[old_registered_email]
							   ,[old_WINKs_in_eWallet]
							   ,[old_points_in_eWallet]
							   ,[old_last_expired_evoucher]
							   ,[old_registered_phone_no]
							   ,[old_whatsapp_phone_no]
							   ,[old_diasbled_date]
							   ,[old_whatsapp_received_date]
							   ,[old_email_request_status]
							   ,[old_whatsapp_request_status]
							   ,[old_offender_status]
							   ,[old_reason]
							   ,[old_confiscated_status]
							   ,[old_confiscation_batch]
							   ,[old_filtering_status]
							   ,[old_unlocked_date]
							   ,[old_remark]
							   ,created_at
							  -- ,old_account_filtering_id 
							   ,enquiry_received_date
							   
							   )
					 SELECT     @action_id ,
								[customer_id]
							   ,[registered_email]
							   ,[WINKs_in_eWallet]
							   ,[points_in_eWallet]
							   ,[last_expired_evoucher]
							   ,[registered_phone_no]
							   ,[whatsapp_phone_no]
							   ,[diasbled_date]
							   ,[whatsapp_received_date]
							   ,[email_request_status]
							   ,[whatsapp_request_status]
							   ,[offender_status]
							   ,[reason]
							   ,[confiscated_status]
							   ,[confiscation_batch]
							   ,[filtering_status]
							   ,[unlocked_date]
							   ,[remark]
							   ,@current_date
							  --- ,@account_filtering_id 
							   ,enquiry_received_date

							   FROM wink_account_filtering
					           WHERE id = @account_filtering_id


					END
					END
					Set @result = 1
		END TRY

		BEGIN CATCH

		Set @result =2
		return 
        END CATCH


	
END
 
--SELECT * FROM [wink_account_filtering_olddata_log]


--SELECT * FROM [wink_account_filtering_newdata_log]
