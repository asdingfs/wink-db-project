CREATE PROCEDURE [dbo].[Create_WINK_News]
(
	@admin_email varchar(50),
	@news varchar(2000),
	@news_status varchar(10),
	@title varchar(100))
AS
BEGIN
DECLARE @RETURN_NO VARCHAR(10)

    DECLARE @current_date datetime
    EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date OUTPUT
	--check admin_email is null or not
	IF(@admin_email = '' OR @admin_email is null)
	BEGIN
		SET @RETURN_NO='001';                    
			GOTO Err
	END

	IF NOT EXISTS(SELECT * FROM admin_user where email = @admin_email)
	BEGIN
		SET @RETURN_NO='001';                    
		GOTO Err
	END

	DECLARE @maxID int
	DECLARE @news_id int
	

	INSERT INTO [wink_news] (news,news_status,title,created_at,updated_at)
	VALUES (@news,@news_status,@title,@current_date,@current_date)
	SET @maxID = (SELECT @@IDENTITY);
	
	IF (@maxID > 0)
    BEGIN
		SET @news_id  =  (SELECT SCOPE_IDENTITY());

		if(@news_id is null or @news_id = 0)
		BEGIN
			Delete from wink_news where id = @news_id;
			SET @RETURN_NO='001';                    
			GOTO Err
		END

		---Start Create Log 
		Declare @result int
		---Call Push Log Storeprocedure Function 
		EXEC Create_News_Log
		@admin_email,@news_id,@title,@news,@news_status,'New','News', @result output;
			
		if(@result=1)
		BEGIN
			select '1' as response_code , 'Successfully created new record' as response_message, @news_id as news_id;
			return
		END
		ELSE
		BEGIN
			Delete from wink_news where id = @news_id;
			SET @RETURN_NO='001';                    
			GOTO Err
		END
		
	END
	ELSE 
	BEGIN
		SET @RETURN_NO='001';                    
		GOTO Err
	END

	Err:                                         
	IF @RETURN_NO='001'                    
	BEGIN 
	    select '0' as response_code , 'Failed to create' as response_message;
		return                  
	END 
END
