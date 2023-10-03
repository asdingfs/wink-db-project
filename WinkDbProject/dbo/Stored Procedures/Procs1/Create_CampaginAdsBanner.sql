CREATE Procedure [dbo].[Create_CampaginAdsBanner]
(
 @campaign_id int,
 @small_image_name varchar(200),
 @small_image_url varchar(200),
 @small_image_status varchar(10),
 @large_image_name varchar(200),
 @large_image_url varchar(200),
 @result varchar(10) out

)
AS
BEGIN
Declare @current_date datetime
Declare @maxID int 
Exec GET_CURRENT_SINGAPORT_DATETIME @current_date output
insert into campaign_small_image (campaign_id,small_image_name,small_image_url,small_image_status,created_at,updated_at)
values (@campaign_id,@small_image_name,@small_image_url,@small_image_status,@current_date,@current_date)

  SET @maxID = (SELECT @@IDENTITY);
  if(@maxID>0) -- Insert large Image
  Begin
  
  if(@large_image_name is not null and @large_image_name !='')
  BEGIN
  Set @maxID =0;
  insert into campaign_large_image (campaign_id,large_image_name,large_image_url,large_image_status,created_at,updated_at)
  values (@campaign_id,@large_image_name,@large_image_url,'1',@current_date,@current_date)
  SET @maxID = (SELECT @@IDENTITY);
   
  END
  END
 
  if(@maxID>0)
  Begin
  Set @result = '1'
  return
  END
   Else 
   Begin
   Set @result = '0'
   return
   End

END
