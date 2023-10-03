CREATE PROCEDURE  [dbo].[Update_Loading_AdsImage_App] 
(
    @id int,
     @name varchar(150),
    @iphone6plus_image varchar(250) ,
    @iphone6_image varchar(250) ,
	 @iphone5_image varchar(250) ,
	  @android_image varchar(250) ,
	 @url varchar(250) ,
	 @image_status varchar(10),
  @from_date varchar(10),
  @to_date varchar(10),
  @iphoneX_image varchar(250)
	 
)
AS
BEGIN 
DECLARE @current_date datetime
EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date OUTPUT
if(@from_date ='')
set @from_date=null
if(@to_date='')
set @to_date=null

Update app_loading_page set iphone6plus_image =@iphone6plus_image,
iphone6_image= @iphone6_image,iphone5_image=@iphone5_image,
android_image =@android_image,image_status=@image_status,
updated_at=@current_date,
from_date= @from_date,
to_date= @to_date,
url = @url,
name= @name,
iphoneX_image= @iphoneX_image
where id = @id

If(@@ROWCOUNT>0)
select '1' as response_code , 'Successfully updated' as response_message
Else 
select '0' as response_code , 'Failed to update' as response_message

 
END
