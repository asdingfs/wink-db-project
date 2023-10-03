CREATE PROCEDURE  [dbo].[Update_WINKGo_Asset] 
(  
	@id int,
    @name varchar(150),
    @image [varchar](250) ,
    @url [varchar](250) ,
	@campaign_id int ,
	@points int ,
	@interval int ,
	@status [varchar](10) ,
  @from_date varchar(10),
  @to_date varchar(10),
  @admin_email varchar(50) 
	 
)
AS
BEGIN 
DECLARE @current_date datetime


EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date OUTPUT
if(@from_date ='')
set @from_date=null
if(@to_date='')
set @to_date=null

 Declare 
 @old_id int,
 @old_campaign_id int,
 @old_campaign_name varchar(255),
 @old_image varchar(255),
 @old_url varchar(255),
 @old_points int,
 @old_interval int,
 @old_from_date datetime,
 @old_to_date datetime,
 @old_created_at datetime,
 @old_updated_at datetime,
 @old_status varchar(10),

 @result int

 --disable enabled status
 IF @status='1'
	BEGIN
		IF EXISTS (SELECT 1 FROM  ASSET_WINKGO where campaign_id=@campaign_id and status='1' and id!=@id)
		BEGIN
			select TOP 1 @old_id=id, @old_campaign_id=campaign_id, @old_campaign_name=[name], @old_image=[image], @old_url=[url],
			 @old_points=points, @old_interval=interval, @old_from_date=from_date, @old_to_date=to_date, @old_created_at=created_at,
			@old_updated_at=updated_at, @old_status=[status] from asset_winkgo where campaign_id=@campaign_id and status='1' and id!=@id
			
			update ASSET_WINKGO set [status]='0' where id=@old_id
			EXEC CreateWinkGoAssetLog @old_id,
			@old_campaign_id , @old_campaign_name, @old_from_date, @old_to_date, @old_image, @old_url, @old_points, 
			@old_interval, @old_status,  @old_created_at,@old_updated_at,
			@admin_email,'Winkgoasset','Edit',@result output 
		END
	END	

	--save current
 select @old_campaign_id=campaign_id, @old_campaign_name=[name], @old_image=[image], @old_url=[url],
 @old_points=points, @old_interval=interval, @old_from_date=from_date, @old_to_date=to_date, @old_created_at=created_at,
 @old_updated_at=updated_at, @old_status=[status] from asset_winkgo where id=@id


update asset_winkgo set  image=@image, url=@url, updated_at=@current_date,[status]=@status where id=@id

If(@@ROWCOUNT>0)
BEGIN
   
	--save log
	EXEC CreateWinkGoAssetLog @id,
	@old_campaign_id , @old_campaign_name, @old_from_date, @old_to_date, @old_image, @old_url, @old_points, 
	@old_interval, @old_status,  @old_created_at,@old_updated_at,
	@admin_email,'Winkgoasset','Edit',@result output 
	
select '1' as response_code , 'Successfully updated' as response_message
END
Else 
select '0' as response_code , 'Fail to update record' as response_message

 
END