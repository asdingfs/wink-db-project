CREATE PROCEDURE  [dbo].[Create_LoadingPage_AdsImage_App] 
(    @name varchar(150),
	@android_image varchar(250) ,
	@iphone5_image varchar(250) ,
	@iphone6_image varchar(250) ,
    @iphone6plus_image varchar(250) ,
    @image_status varchar(10),
	 @from_date varchar(10),
  @to_date varchar(10),
	 
	 @url varchar(250) ,
	 
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

Insert into app_loading_page (iphone6plus_image,iphone6_image,iphone5_image,android_image,image_status,created_at,updated_at,from_date,to_date,[url],[name],iphoneX_image)
values (@iphone6plus_image,@iphone6_image,@iphone5_image,@android_image,@image_status,@current_date,@current_date,@from_date,@to_date,@url,@name,@iphoneX_image)

If(@@ROWCOUNT>0)
select '1' as response_code , 'Successfully created' as response_message
Else 
select '0' as response_code , 'Failed to create new record' as response_message

 
END

--alter table app_loading_page add iphoneX_image varchar(250)