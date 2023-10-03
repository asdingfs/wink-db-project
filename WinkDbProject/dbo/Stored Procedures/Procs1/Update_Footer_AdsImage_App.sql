CREATE PROCEDURE  [dbo].[Update_Footer_AdsImage_App] 
(
	@id int,
	@name varchar(150),
	@iphone6plus_image varchar(250) ,
	@iphone6_image varchar(250) ,
	@iphone5_image varchar(250) ,
	@android_small_image varchar(250) ,
	@android_large_image varchar(250) ,
	@url varchar(250) ,
	@image_status varchar(10),
	@from_date varchar(10),
	@to_date varchar(10),
	@redirect_to_winktag int,
	@redirect_to_winktreats int,
	@home_status int = 1,
	@iphoneX_image varchar(250) = ''
)
AS
BEGIN 
	DECLARE @current_date datetime
	EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date OUTPUT
	IF(@from_date ='')
	BEGIN
		SET @from_date=null;
	END
	IF(@to_date='')
	BEGIN
		SET @to_date=null;
	END

	Update footer_ads_app 
	SET iphone6plus_image =@iphone6plus_image,
	iphone6_image= @iphone6_image,iphone5_image=@iphone5_image,
	image_status=@image_status,
	android_large_image = @android_large_image,
	android_small_image = @android_small_image,
	updated_at=@current_date,
	from_date= @from_date,
	to_date= @to_date,
	[url] = @url,
	[name]=@name,
	redirect_to_winktag = @redirect_to_winktag,
	redirect_to_winktreats = @redirect_to_winktreats,
	home_status =@home_status,
	iphoneX_image=@iphoneX_image
	where id = @id

	IF(@@ROWCOUNT>0)
	BEGIN
		SELECT '1' as response_code , 'Successfully updated' as response_message
	END
	ELSE
	BEGIN
		SELECT '0' as response_code , 'Failed to update' as response_message
	END
END

