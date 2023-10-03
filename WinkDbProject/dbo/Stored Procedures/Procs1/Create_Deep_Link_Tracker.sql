CREATE PROCEDURE [dbo].[Create_Deep_Link_Tracker]
(
 @dlSource varchar(200),
 @authToken varchar(150),
 @ipAddress varchar(20)
 )
As
BEGIN
	Declare @customer_id int
	Declare @current_date datetime

	Exec GET_CURRENT_SINGAPORT_DATETIME @current_date output

	IF(@ipAddress is null or @ipAddress ='')
	BEGIN
		SET @ipAddress = NULL;
	END

	select @customer_id =c.customer_id from customer  as c where c.auth_token = @authToken
	IF(@dlSource is not null and @dlSource !='')
	BEGIN
		INSERT INTO [dbo].[microsite_ads_tracker]
			   ([source]
			   ,[url]
			   ,[customer_id]
			   ,[created_at]
			   ,[updated_at]
			   ,[ip_address])
		 VALUES
			   (('Deep Link: '+@dlSource)
			   ,''
			   ,@customer_id
			   ,@current_date
			   ,@current_date
			   ,@ipAddress)

		IF(@@ROWCOUNT>0)
		BEGIN
			select '1' as success , 'successful' as response_message;
		END
		ELSE
		BEGIN 
			select '0' as success , 'failed' as response_message;
		END
	END
END