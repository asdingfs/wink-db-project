CREATE Procedure [dbo].[LinkAsmToCampaignId]
(           @asset_type_management_id int
          
           ,@campaign_id int
          
)
AS
BEGIN

    Declare     @station_name varchar(255)
    Declare     @asset_code varchar(150)
    Declare     @asset_name varchar(150)
    Declare     @station_id int
    Declare     @scan_value int
    Declare     @scan_interval decimal(10,2)
    Declare     @qr_code_value varchar(255)
    Declare     @created_at DateTime
    Declare     @updated_at DateTime
    Declare     @station_group_id int
    Declare     @station_code varchar(150)
    Declare     @booking_id int 
    Declare     @merchant_id int 
    Declare     @start_date DateTime
    Declare     @end_date DateTime
    Declare     @image_id int
    Declare     @image_name varchar(150)
    Declare     @image_url varchar(150)
    Declare     @RETURN_NO varchar(10)
   
	
     BEGIN
     
     IF EXISTS(Select campaign_id from campaign where campaign.campaign_id =@campaign_id)
     BEGIN
     Select @merchant_id = merchant_id , @start_date = campaign_start_date,
     @end_date = campaign_end_date  from campaign where campaign.campaign_id = @campaign_id
     END
     ELSE 
     BEGIN
     print('error campaign');
		 SET @RETURN_NO='001' -- No Campaign Id                          
		 GOTO Err
	End
	
     
     
     IF EXISTS (Select asset_type_management.asset_type_management_id from asset_type_management)
     BEGIN 
     print('asset type ok');
     Select @scan_value = scan_value,
            @scan_interval = scan_interval,
            @asset_name = asset_name,
            @asset_code = asset_code,
            @station_code = station_code,
            @station_id  = station_id,
            @qr_code_value = qr_code_value,
            @station_group_id = station_group_id
            
      from asset_type_management where asset_type_management.asset_type_management_id = @asset_type_management_id
      and (asset_type_management.scan_end_date ='' or scan_end_date is null or scan_start_date is null or scan_end_date ='')
     
     END
     ELSE 
     BEGIN
     print('NO asset type ');
     SET @RETURN_NO='002' -- No Asset ID                          
	 GOTO Err
	 END
     
     --- CHECK ALREADY BOOKED 
     
    IF NOT EXISTS (Select booking_id from asset_management_booking 
	Where Lower(asset_management_booking.asset_type_name) = Lower(@asset_name)
	AND Lower(asset_management_booking.asset_type_code) = Lower(@asset_code)
	AND asset_management_booking.station_id = @station_id
	AND 
	(@start_date BETWEEN asset_management_booking.start_date AND asset_management_booking.end_date
	OR @end_date BETWEEN asset_management_booking.start_date AND asset_management_booking.end_date)
	AND asset_management_booking.booked_status ='true'
	)
	
	BEGIN
     
     select @image_id=m.id,@image_name=m.small_image_name,@image_url=m.small_image_url from campaign_small_image as m where campaign_id =@campaign_id
     and m.small_image_status =1
     
     INSERT INTO asset_management_booking
           ([campaign_id]
           ,[asset_type_management_id]
           ,[scan_value]
           ,[scan_interval]
           ,[start_date]
           ,[end_date]
           ,[created_at]
           ,[updated_at]
           ,[merchant_id]
           ,[station_id]
           ,[station_code]
           ,[asset_type_name]
           ,[asset_type_code]
           ,[qr_code_value]
           ,[station_group_id]
           ,image_id
           ,image_name
           ,image_url
           
           
           )
     VALUES
           (@campaign_id
           ,@asset_type_management_id
           ,@scan_value
           ,@scan_interval
           ,@start_date
           ,@end_date
           ,GETDATE()
           ,GETDATE()
           ,@merchant_id
           ,@station_id
           ,@station_code
           ,@asset_name
           ,@asset_code
           ,@qr_code_value
           ,@station_group_id
           ,@image_id
           ,@image_name
           ,@image_url
           
           )
           
           
      
      IF(@@ROWCOUNT>0)
						BEGIN
							SET @RETURN_NO='000' -- SUCCESS                           
							GOTO Err
						END
						ELSE	
						BEGIN 
							SET @RETURN_NO='003' -- INSERT FAIL                         
							GOTO Err
						END 
      
      
    END
    ELSE 
    
		BEGIN
			SET @RETURN_NO='003' -- ALREADY BOOKED                         
							GOTO Err
		
		END
    
    END
    Err:                                         
	IF @RETURN_NO='001'                           
	BEGIN                                              
		SELECT '0' as response_code, 'Campaign does not exist' as response_message 
		RETURN                           
	END 
	ELSE IF @RETURN_NO='002' 
	BEGIN  
		SELECT '0' as response_code, 'Asset Type does not exist' as response_message 
		RETURN 
	END
	ELSE IF @RETURN_NO='003' 
	BEGIN  
		SELECT '0' as response_code,'Asset Type is not avaiable for selecting date' as response_message
	RETURN 
	END
	ELSE IF @RETURN_NO='000' 
	BEGIN  
		SELECT '1' as response_code,'Success' as response_message
	RETURN 
	END 

END

