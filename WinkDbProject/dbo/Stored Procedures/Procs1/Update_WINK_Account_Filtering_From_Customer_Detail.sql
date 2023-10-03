
CREATE PROCEDURE  [dbo].[Update_WINK_Account_Filtering_From_Customer_Detail] 
(
    @customer_id int ,
	
	@admin_user_email varchar(100),
	
	@confiscated_status varchar(10),
	@unlocked_status varchar(10),
	@reason varchar(255)
	--@whatspp_matching_status varchar(30)
	)
AS
BEGIN 
DECLARE @current_date datetime,
@account_filtering_id int





DECLARE @maxID int
DECLARE	@action_role_id int,
		@admin_name varchar(100)
	


	


	EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date output

	-------------1. GET THE ACTION USER ROLE 
		SET @action_role_id =0
		SELECT @action_role_id = admin_role_id, @admin_name = (admin_user.first_name+' '+ admin_user.last_name) from admin_user where email =@admin_user_email
		----- 1.2 ----UPDATE ACTION DATE BY ROLE 

	
		BEGIN
		
		---1.1 UNLOCK THE ACCOUNT FROM CUSTOMER TAB
			IF (@unlocked_status ='Yes' )
				BEGIN
				--- GET THE LATEST ID OF THE ACCOUNT FILTER BY CUSTOMER ID
				
					SELECT  @account_filtering_id = max(w.id) FROM wink_account_filtering as w,
					wink_account_filtering_status_new as n
					
					 WHERE Customer_id = @customer_id 
					 and n.filtering_status_key = w.filtering_status
					 and n.filter_procedure_key != 'close'

				IF( @account_filtering_id !=0)
					BEGIN
						IF EXISTS (select 1 from customer where customer_id = @customer_id and status ='enable')
						BEGIN
						UPDATE [wink_account_filtering] SET  unlocked_date= @current_date,
						filtering_status ='done'
						, updated_at = @current_date

						WHERE ID = @account_filtering_id
						END
					END
					
				END 
				
			--1.2 CONFISCATION DONE STATUS FROM CUSTOMER TAB

			ELSE IF(@confiscated_status ='Done')
				BEGIN
					SELECT  @account_filtering_id = max(w.id) FROM wink_account_filtering as w,
					wink_account_filtering_status_new as n
					
					 WHERE Customer_id = @customer_id 
					 and n.filtering_status_key = w.filtering_status
					 and n.filter_procedure_key != 'close'

					IF( @account_filtering_id !=0)
					BEGIN
						IF EXISTS (select 1 from customer where customer_id = @customer_id and status ='disable')
						BEGIN
							--- CHECK eVoucher
							IF NOT EXISTS (select 1 from customer_earned_evouchers where customer_id =
							@customer_id and cast(created_at as date) < cast(@current_date as date))
							BEGIN
									UPDATE [wink_account_filtering] SET  confiscated_status= @confiscated_status
								   , updated_at = @current_date
								   ,filtering_status = 'done'
									WHERE ID = @account_filtering_id
							END
						END
					END

				END 

			---1.3 UPDATE REASON FROM CUSTOMER DETAIL
			ELSE IF(@reason !='')
				BEGIN

				Print ('1.3 UPDATE REASON FROM CUSTOMER DETAIL')

				SELECT  @account_filtering_id = max(ID) FROM wink_account_filtering WHERE Customer_id = @customer_id

				UPDATE [wink_account_filtering] SET  reason = @reason , updated_at = @current_date
				
				WHERE ID = @account_filtering_id

				END 

		END


		
	




END
