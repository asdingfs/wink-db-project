CREATE PROCEDURE  [dbo].[Create_Popup_AdsImage_App] 
(   @name varchar(150),
	@iphone6plus_image varchar(250) ,
	@iphone6_image varchar(250) ,
	@iphone5_image varchar(250) ,
	@android_image varchar(250) ,
	@url varchar(250) ,
	@image_status varchar(10),
	@from_date varchar(10),
	@to_date varchar(10),
	@redirect_to_winktag int,
	@redirect_to_winktreats int,
	@home_status int,
	@iphoneX_image varchar(250),
	@iphone8_image varchar(250),
	@iphone8plus_image varchar(250),
	@iphone11_image varchar(250),
	@iphone14_image varchar(250)
)
AS
BEGIN 
	DECLARE @current_date datetime
	DECLARE @redirect_status int

	EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date OUTPUT
	IF(@from_date ='')
	BEGIN
		SET @from_date = NULL;
	END
	IF(@to_date='')
	BEGIN
		SET @to_date = NULL;
	END

	IF( (@url is null) or (LTRIM(RTRIM(@url)) = '') OR @redirect_to_winktag =1 OR @redirect_to_winktreats = 1)
	BEGIN
		SET @redirect_status = 0;
	END
	ELSE
	BEGIN
		SET @redirect_status = 1;
	END


	Insert into popup_ads_app (iphone6plus_image,iphone6_image,iphone5_image,android_image,image_status,created_at,updated_at,from_date,
	to_date,[url],[name],redirect_status,redirect_to_winktag,redirect_to_winktreats,home_status,iphoneX_image,iphone8_image,iphone8plus_image,iphone11_image,iphone14_image)
	values (@iphone6plus_image,@iphone6_image,@iphone5_image,@android_image,@image_status,
	@current_date,@current_date,@from_date,@to_date,@url,@name,@redirect_status,@redirect_to_winktag,@redirect_to_winktreats,@home_status,
	@iphoneX_image,@iphone8_image,@iphone8plus_image,@iphone11_image,@iphone14_image)

	IF(@@ROWCOUNT>0)
	BEGIN
		SELECT '1' as response_code , 'Successfully created' as response_message
	END
	ELSE 
	BEGIN
		SELECT '0' as response_code , 'Failed to create new record' as response_message
	END
 
END
