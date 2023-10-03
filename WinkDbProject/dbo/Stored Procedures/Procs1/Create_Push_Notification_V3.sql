CREATE PROCEDURE [dbo].[Create_Push_Notification_V3]
(
	@admin_email varchar(50),
	@notification_message nvarchar(1000),
	@created_on datetime,
	@title nvarchar(500),
	@img_url varchar(1000),
	@page varchar(250),
	@type varchar(100)
)
AS
BEGIN
	--check admin_email is null or not
	IF(@admin_email = '' OR @admin_email is null)
		return -1;

	IF NOT EXISTS(SELECT * FROM admin_user where email = @admin_email)
		return -1;

	DECLARE @maxID int
	DECLARE @push_id int

	IF(@type = '' or @type is null)
	BEGIN
		set @type = 'Everyone';
	END

	INSERT INTO push_notification (notification_message,created_on,notification_title, img_url, goToPage, type)
	VALUES (@notification_message,@created_on,@title,@img_url, @page, @type);

	SET @maxID = (SELECT @@IDENTITY);

	IF (@maxID > 0)
    BEGIN
		SET @push_id  =  (SELECT SCOPE_IDENTITY());

		if(@push_id is null or @push_id = 0)
		BEGIN
			Delete from push_notification where id = @push_id
			return -1;
		END

		---Start Create Log 
		Declare @result int
		---Call Push Log Storeprocedure Function 
		EXEC Create_Push_Notification_Log
		@admin_email,@push_id,'New',@result output;
			
		--print (@result)
		if(@result=2)
		BEGIN
			Delete from push_notification where id = @push_id
			return -1;
		END
	END
	ELSE
		return -1;
		   
END
