CREATE PROCEDURE  [dbo].[Create_WINKGo_Asset] 
(   @name varchar(150),
    @image [varchar](250) ,
    @url [varchar](250) ,
	@campaign_id int ,
	@points int ,
	@interval int ,
	@status [varchar](10) ,
  @from_date varchar(10),
  @to_date varchar(10),
  @admin_email varchar(100) 
	 
)
AS
BEGIN 
DECLARE @current_date datetime
DECLARE @result int

EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date OUTPUT
if(@from_date ='')
set @from_date=null
if(@to_date='')
set @to_date=null



BEGIN TRANSACTION;
SAVE TRANSACTION InsertWinkgoSavePoint;

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
 @old_status varchar(10)

BEGIN TRY
	
		IF EXISTS (SELECT 1 FROM  ASSET_WINKGO where campaign_id=@campaign_id  )
		BEGIN
			delete from ASSET_WINKGO where campaign_id=@campaign_id 
		END
	
	Insert into asset_winkgo ([name],[image],[url],campaign_id,points,interval,created_at,updated_at,from_date,to_date,[status])
	values (@name,@image,@url,@campaign_id,@points,@interval,@current_date,@current_date,@from_date,@to_date,@status)

	--If(@@ROWCOUNT>0)

		--BEGIN
		EXEC CreateWinkGoAssetLog
		0,
		@campaign_id , '', '', '', '', '', 1, 24, '0',@current_date ,@current_date,
		@admin_email,'winkgoasset','New',@result output 
		select '1' as response_code , 'Successfully created' as response_message
		--END
	--Else 
	
	COMMIT TRANSACTION 
END TRY
 BEGIN CATCH
        IF @@TRANCOUNT > 0
        BEGIN
            ROLLBACK TRANSACTION InsertWinkgoSavePoint; -- rollback to MySavePoint
			select '0' as response_code , 'Fail to create new record' as response_message
        END
    END CATCH
END
