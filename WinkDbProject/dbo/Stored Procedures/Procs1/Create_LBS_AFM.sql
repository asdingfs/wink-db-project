
CREATE PROCEDURE  [dbo].[Create_LBS_AFM] 
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
			@account_filtering_id int,
			@locked_by varchar(100),
			@locked_reason varchar(2000);
	
	IF(@admin_user_email is null or @admin_user_email = '')
	BEGIN
		SET @locked_by ='System';
	END

	EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date OUTPUT
	SET @diasbled_date = @current_date;

	SET @filtering_status ='new';
	SET @whatsapp_request_status ='No';
	SET  @email_request_status ='';
 	SET @locked_reason = @reason + '  Ask for stations scanned on that day.';
   
	---1. GET CUSTOMER DATA
	---1.1 GET THE CUSTOMER WINK BALANCED
	SET @points_in_eWallet = (select (total_points-(used_points+confiscated_points)) from customer_balance where customer_id = @customer_id);
		
	---1.2 GET THE CUSTOMER POINT BALANCED
	SET @WINKs_in_eWallet = (select (total_winks-(used_winks+confiscated_winks)) from customer_balance
	where customer_id =@customer_id);

	----1.3 GET CUSTOMER EXPIRED EVOUCHER DATE
	IF EXISTS (select 1 from customer_earned_evouchers where 
	cast(expired_date as date) >=cast(@current_date as date) and customer_id =@customer_id and used_status = 0)
	BEGIN
		SET @last_expired_evoucher = (select TOP 1 cast(expired_date as date) from customer_earned_evouchers where 
		cast(expired_date as date) >=cast(@current_date as date) and customer_id =@customer_id and used_status = 0 order by expired_date desc);
	END
		
	----1.4 GET OFFENDER STATUS
	SET @offender_status = (SELECT COUNT(*) FROM [wink_account_filtering] WHERE CUSTOMER_ID = @customer_id) + 1;

	----1.5 GET REGISTERED PHONE NO.
	SELECT @registered_phone_no=phone_no, @registered_email = email  FROM customer WHERE customer_id = @customer_id;

	----1.6 GET Admin ID
	SELECT @locked_by =first_name+' '+last_name from admin_user where email =@admin_user_email;

	IF(Ltrim(Rtrim(@locked_by))='' OR  @admin_user_email is null)
	BEGIN
		SET @locked_by ='System';
	END
	
	IF NOT EXISTS (SELECT 1 FROM wink_account_filtering WHERE  customer_id =@customer_id and (filtering_status !='done' and filtering_status !='verified') )
	BEGIN
		IF((SELECT COUNT(*) from wink_account_filtering 
		WHERE filtering_status = 'done'
		AND customer_id =@customer_id
		AND reason like '%no location data received.%' ) >=2 )
		BEGIN
			DECLARE @prevDone datetime
			SET @prevDone = 
			(SELECT TOP(1) created_at from wink_account_filtering 
			where customer_id =@customer_id 
			and filtering_status = 'done' 
			AND reason like '%no location data received.%'
			order by created_at desc);

			DECLARE @autoUnlockCount int;
			SELECT @autoUnlockCount = COUNT(*) 
			from wink_account_filtering 
			where customer_id =@customer_id 
			and filtering_status = 'verified'
			and created_at > @prevDone;
			
			DECLARE @verified_email varchar(100);
			DECLARE @verified_phone_no varchar(10);

			SELECT TOP(1) @verified_email = registered_email, @verified_phone_no = whatsapp_phone_no from wink_account_filtering where filtering_status ='done' and customer_id =@customer_id order by created_at desc;
				

			IF((@autoUnlockCount=0) or (@autoUnlockCount%3 != 0))
			BEGIN
				
				
				IF((@verified_email like @registered_email) AND (@verified_phone_no like @registered_phone_no))
				BEGIN
					SET @reason = @reason + ' Status verified and account unlocked.';
					SET @filtering_status = 'verified';
				END
				ELSE
				BEGIN
					SET @reason = @locked_reason;
				END
			END
			ELSE
			BEGIN
				DECLARE @prevVerify datetime
				SET @prevVerify = (SELECT TOP(1) created_at from wink_account_filtering where customer_id =@customer_id and filtering_status = 'verified' order by created_at desc);
				IF EXISTS (SELECT 1 FROM wink_account_filtering 
				where customer_id =@customer_id 
				and filtering_status = 'done' 
				and created_at >@prevVerify
				AND reason like '%no location data received.%')
				BEGIN

					IF((@verified_email like @registered_email) AND (@verified_phone_no like @registered_phone_no))
					BEGIN
						SET @reason = @reason + ' Status verified and account unlocked.';
						SET @filtering_status = 'verified';
					END
					ELSE
					BEGIN
						SET @reason = @locked_reason;
					END
				END
				ELSE
				BEGIN
					SET @reason = @locked_reason;
				END
				
			END	
		END
		ELSE
		BEGIN
			SET @reason = @locked_reason;
		END	

		IF(@filtering_status like 'new')
		BEGIN
			Update customer 
			set customer.status = 'disable',
			customer.updated_at = @current_date 
			where customer.customer_id = @customer_id;
		END

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
					,Locked_by
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
					@locked_by,
					@current_date,
					@current_date);
		IF(@@ROWCOUNT>0)
		BEGIN
			IF(@filtering_status like 'new')
			BEGIN
				RETURN 0;
			END
			ELSE
			BEGIN
				RETURN 1;
			END
		END
	END
	ELSE 
	BEGIN
		RETURN 0;
	END
END




