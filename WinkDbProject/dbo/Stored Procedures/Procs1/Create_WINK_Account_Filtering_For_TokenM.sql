
Create PROCEDURE  [dbo].[Create_WINK_Account_Filtering_For_TokenM] 
(
    @customer_id int ,
	@reason varchar(2000) ,
	@admin_user_email varchar(100)
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
		@whatsapp_received_date datetime ,
	    @confiscation_batch varchar(50),
		@whatsapp_phone_no varchar(10) ,
	    @email_request_status varchar(10) ,
		@whatsapp_request_status varchar(10),
		@filtering_status varchar(20),
	
		@confiscated_status varchar(10) ,
		@unlocked_date datetime ,
		@remark varchar(2000) ,
	
		@account_filtering_id int
	
	
	   

--SET @offender_status = 1
	--- SET CURRENT DATE
	EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date OUTPUT
	---SET DISABLED DATE 
	SET @diasbled_date = @current_date

	--SET FILTERING STATUS 

	SET @filtering_status ='pending_enquiry'

	---SET DEFAULT WHATSAPP STATUS 
	SET @whatsapp_request_status ='No'
	SET  @email_request_status ='No'
 	 

	/* ---CHECK THE ACCOUNT FILTERING STATUS TO AVOID LOOP 
		IF EXISTS (SELECT 1 FROM [wink_account_filtering] AS F WHERE F.filtering_status !='Done')
		BEGIN
		
		
		END */

	--- CHECK THE ACCOUNT MUST BE LOCKED
	IF EXISTS (SELECT 1 FROM customer WHERE customer_id = @customer_id and status ='disable')
	BEGIN
	    
	---1. GET CUSTOMER DATA
		---1.1 GET THE CUSTOMER WINK BALANCED
		SET @points_in_eWallet = (select (total_points-(used_points+confiscated_points)) from customer_balance where customer_id = @customer_id)
		
		---1.2 GET THE CUSTOMER POINT BALANCED
		SET @WINKs_in_eWallet = (select (total_winks-(used_winks+confiscated_winks)) from customer_balance
		where customer_id =@customer_id)

		----1.3 GET CUSTOMER EXPIRED EVOUCHER DATE
		IF EXISTS (select 1 from customer_earned_evouchers where 
		cast(expired_date as date) >cast(@current_date as date) and customer_id =@customer_id)
			BEGIN
			SET @last_expired_evoucher = (select TOP 1 cast(expired_date as date) from customer_earned_evouchers where 
		    cast(expired_date as date) >cast(@current_date as date) and customer_id =@customer_id)
			END
		
		----1.4 GET OFFENDER STATUS
		SET @offender_status = (SELECT COUNT(*) FROM [wink_account_filtering] WHERE CUSTOMER_ID = @customer_id) + 1

		----1.5 GET REGISTERED PHONE NO.

		SELECT @registered_phone_no=phone_no, @registered_email = email  FROM customer WHERE customer_id = @customer_id

		END
	ELSE -- ACCOUNT NOT LOCK (RETURN 0)
	BEGIN
	RETURN 0
	END
	IF NOT EXISTS (SELECT 1 FROM wink_account_filtering WHERE filtering_status !='done' and customer_id =@customer_id)
			BEGIN
			INSERT INTO [dbo].[wink_account_filtering]
					   ([customer_id]
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
					   ,updated_at)
			   values (@customer_id ,
				@registered_email  ,
				@WINKs_in_eWallet  ,
				@points_in_eWallet,
				@last_expired_evoucher ,
				@registered_phone_no  ,
				@whatsapp_phone_no  ,
				@diasbled_date  ,
				@whatsapp_received_date  ,
				@email_request_status  ,
				@whatsapp_request_status ,
				@offender_status  ,
				@reason  ,
				@confiscated_status  ,
				@confiscation_batch  ,
				@filtering_status  ,
				@unlocked_date  ,
				@remark,
				@current_date,
				@current_date)
	END
	ELSE IF EXISTS (select 1 from wink_account_filtering where filtering_status !='done' and customer_id = @customer_id)
	BEGIN
		
		Declare @old_locked_reson_before_tokenM varchar(255)
		Declare @old_filtering_id int
		set @old_filtering_id = 0

		select top 1 @old_locked_reson_before_tokenM =[reason] , @old_filtering_id = wink_account_filtering.id from wink_account_filtering where filtering_status !='done' and customer_id = @customer_id
		order by id desc
		IF (@old_filtering_id !=0)
		BEGIN		
		update wink_account_filtering set reason = CONCAT ('(',@reason,')',@old_locked_reson_before_tokenM) where filtering_status !='done' 
		and id = @old_filtering_id

		END

	END
	

----START  ACCOUNT LOCK LOG 
			/*SET @maxID = (SELECT @@IDENTITY);
			 IF (@maxID > 0)
				 BEGIN
				  SET @account_filtering_id  =  (SELECT SCOPE_IDENTITY());
      
				 Declare @result int
			--- Call Campaign Log Storeprocedure Function 

					EXEC Create_WINK_Account_Filtering_Log
					@result  output,
					@customer_id  ,
					@registered_email ,
					@WINKs_in_eWallet  ,
					@points_in_eWallet  ,
					@last_expired_evoucher  ,
					@registered_phone_no  ,
					@whatsapp_phone_no  ,
					@diasbled_date  ,
					@whatsapp_received_date  ,
					@email_request_status  ,
					@whatsapp_request_status  ,
					@offender_status  ,
					@reason  ,
					@confiscated_status  ,
					@confiscation_batch  ,
					@filtering_status  ,
					@unlocked_date  ,
					@remark,
					@admin_user_email ,
					'AccountFiltering' ,
					'New',
					@account_filtering_id ;
			END
			*/ --- END LOG
	/*if(@result=2)
	BEGIN
	/*Delete from campaign where campaign.campaign_id =@campaign_id
	SET @campaign_id=0*/
	END*/
END




