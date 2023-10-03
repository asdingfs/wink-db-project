CREATE PROCEDURE [dbo].[Update_WINK_News]
	(
	 @id int,
	 @news varchar(2000),
	 @news_status varchar(10),
	 @title varchar(100),
	 @admin_email varchar(100))
AS
BEGIN
    DECLARE @current_date datetime
    EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date OUTPUT
	IF(@admin_email is null or @admin_email = '')
	BEGIN
		SELECT '0' as response_code,'You are not authorised to edit the news' as response_message
		return
	END
	IF(@id = 0)
	BEGIN
		SELECT '0' as response_code,'This news does not exist' as response_message
		return
	END
	
	IF(@news is null or @news = '')
	BEGIN
		SELECT '0' as response_code,'News content cannot be empty' as response_message
		return
	END

	IF(@title is null or @title = '')
	BEGIN
		SELECT '0' as response_code,'Please enter a valid title' as response_message
		return
	END

	DECLARE @CURRENT_DATETIME Datetime ;     
	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUTPUT

	DECLARE @old_title varchar(100),
	@old_news varchar(2000),
	@old_status varchar(10);

	SELECT @old_title = title, @old_news = news, @old_status = news_status
	from wink_news
	where id = @id;

    update wink_news 
	set news=@news,news_status = @news_status,title =@title, updated_at =@current_date
    where wink_news.id = @id
		
	If(@@ROWCOUNT>0)
	BEGIN
		Declare @result int
	
		EXEC Create_News_Log
		@admin_email,@id, @old_title, @old_news, @old_status,'Edit','News', @result output ;
		--print (@result)
		if(@result=2)
		BEGIN
			UPDATE [dbo].[wink_news]
			SET [title] = @old_title
				,[news] = @old_news
				,[news_status] = @old_status
				,[updated_at] = @CURRENT_DATETIME
			WHERE id = @id;
			SELECT '0' as response_code,'Please try again later' as response_message
			return
		END
		ELSE
		BEGIN
			select '1' as response_code , 'Successfully updated' as response_message
			return
		END
	END
	ELSE
	BEGIN 
		select '0' as response_code , 'Failed to update' as response_message
	END
END
