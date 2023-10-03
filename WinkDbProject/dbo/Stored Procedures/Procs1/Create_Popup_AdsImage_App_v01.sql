CREATE PROCEDURE  [dbo].[Create_Popup_AdsImage_App_v01] 
(    @name varchar(150),
    @iphone6plus_image [varchar](250) ,
    @iphone6_image [varchar](250) ,
	 @iphone5_image [varchar](250) ,
	  @iphone4_image [varchar](250) ,
	 @android_small_image [varchar](250) ,
	 @android_large_image [varchar](250) ,
	 @url [varchar](250) ,
	 @image_status varchar(10),
  @from_date varchar(10),
  @to_date varchar(10),
  @redirect_to_winktag int 
	 
)
AS
BEGIN 
DECLARE @current_date datetime
DECLARE @redirect_status int

EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date OUTPUT
if(@from_date ='')
set @from_date=null
if(@to_date='')
set @to_date=null

if (@url is null) or (LTRIM(RTRIM(@url)) = '') 
	set @redirect_status = 0
else
	set @redirect_status = 1


Insert into popup_ads_app (iphone6plus_image,iphone6_image,iphone5_image,iphone4_image,image_status,created_at,updated_at,from_date,to_date,url,name,redirect_status,redirect_to_winktag)
values (@iphone6plus_image,@iphone6_image,@iphone5_image,@iphone4_image,@image_status,@current_date,@current_date,@from_date,@to_date,@url,@name,@redirect_status,@redirect_to_winktag)

If(@@ROWCOUNT>0)
select '1' as response_code , 'Successfully created' as response_message
Else 
select '0' as response_code , 'Fail to create new record' as response_message

 
END
