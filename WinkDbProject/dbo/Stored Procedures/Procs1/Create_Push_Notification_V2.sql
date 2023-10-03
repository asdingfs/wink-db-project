CREATE PROCEDURE [dbo].[Create_Push_Notification_V2]
(
	@admin_email varchar(50),
	@notification_message varchar(500),
	@created_on datetime,
	@url varchar(500)
)
AS
BEGIN
	--check admin_email is null or not
	IF(@admin_email = '' OR @admin_email is null)
		return -1;



	DECLARE @maxID int
	DECLARE @push_id int

	INSERT INTO push_notification (notification_message,created_on,url)
	VALUES (@notification_message,@created_on,@url)

	SET @maxID = (SELECT @@IDENTITY);

	IF (@maxID > 0)
    BEGIN
		SET @push_id  =  (SELECT SCOPE_IDENTITY());
		print('Push ID is ')
		print(@push_id)
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
			
		/*
		--print (@result)
		if(@result=2)
		BEGIN
			Delete from push_notification where id = @push_id
			return 0;
		END
		*/
	END   
END