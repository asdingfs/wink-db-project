CREATE PROCEDURE [dbo].[Update_WINK_Fees_By_Id]
	(@id int,
	 @system_value int,
	 @admin_email varchar(50)
	 
     )
AS
BEGIN

	
	DECLARE @old_wink_fee_value Decimal(10,2)
	DECLARE @admin_account_id varchar(10)
	DECLARE @action_id int
	DECLARE @log_id int
	DECLARE @current_date_time datetime
	DECLARE @admin_user_name varchar(50)

	/*SELECT @admin_account_id = admin_user.admin_user_id
	from admin_user where 
	@admin_email = admin_user.email and 
	admin_user.status =1*/

	EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date_time output

	SELECT @admin_account_id=admin_user_id,@admin_user_name = first_name+' '+last_name FROM admin_user AS A WHERE A.email =@admin_email
	and A.status =1

	SELECT @log_id = id FROM admin_log AS A WHERE A.user_id =@admin_account_id

	---- Get Old WINK Fees 



	---- Update WINK Fee

	Update wink_fee SET wink_fee_value = @system_value,updated_at = @current_date_time
    Where wink_fee.id = @id
    
	IF (@@ROWCOUNT >0)
	BEGIN
		INSERT INTO [dbo].[action_log]
           ([log_id]
           ,[action_time]
           ,[admin_user_name]
           ,[admin_user_email]
           ,[action_object]
           ,[action_type]
           ,[action_table_name]
           ,[link_url])
     VALUES
           (@log_id
           ,@current_date_time
           ,@admin_user_name
           ,@admin_email
           ,'WINK Fees'
           ,'Edit'
           ,'wink_fee_new_data_log'
           ,'adminactiondetail/winkfeesdetail')

		   -----AFTER ACTION LOG SAVE OLD DATA AND NEW DATA LOG

		   SELECT  @action_id=MAX(action_id) FROM action_log AS A WHERE A.admin_user_email =@admin_email

		   -----SAVE OLD DATA
		   INSERT INTO [dbo].[wink_fee_old_data_log]
           ([wink_fee_key]
           ,[wink_fee_value]
           ,[name]
           ,[rate_type]
           ,[action_id]
		   ,created_at
		   )
		   SELECT 
			[wink_fee_key]
           ,@old_wink_fee_value
           ,[name]
           ,[rate_type]
           ,@action_id
		   ,@current_date_time
		   FROM wink_fee 
		   WHERE id =@id


		   -----SAVE NEW DATA
		   INSERT INTO [dbo].[wink_fee_new_data_log]
           ([wink_fee_key]
           ,[wink_fee_value]
           ,[name]
           ,[rate_type]
           ,[action_id]
		   ,created_at
		   )
		   SELECT 
			[wink_fee_key]
           ,@system_value
           ,[name]
           ,[rate_type]
           ,@action_id
		   ,@current_date_time

		   FROM wink_fee 
		   WHERE id =@id

		  RETURN

	END
   
	
END

