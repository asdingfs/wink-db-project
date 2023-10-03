CREATE Procedure [dbo].[LinkWinkGoAssetToCampaignId]
(           @asset_winkgo_id int
          
           ,@campaign_id int
          
)
AS
BEGIN

    Declare	   @updated_at DateTime   
    Declare     @start_date DateTime
    Declare     @end_date DateTime
    
    Declare     @RETURN_NO varchar(10)
   
    Declare		@booked_status varchar(50)
	Declare		@asset_campaign_id int
	
     BEGIN
     
		IF EXISTS(Select campaign_id from campaign where campaign.campaign_id =@campaign_id)
     BEGIN
     Select  @start_date = campaign_start_date,
     @end_date = campaign_end_date  from campaign where campaign.campaign_id = @campaign_id
     END
     ELSE 
     BEGIN
     print('error campaign');
		 SET @RETURN_NO='001' -- No Campaign Id                          
		 GOTO Err
	End
	
     
     
		IF EXISTS (Select [id] from ASSET_WINKGO where id = @asset_winkgo_id)
     BEGIN 
		print('asset type ok');
		Select @booked_status = booked_status,
            @asset_campaign_id = campaign_id
            
		from ASSET_WINKGO where id = @asset_winkgo_id
     
		if @booked_status = 'true'
		BEGIN 
		 SET @RETURN_NO='003' -- ALREADY BOOKED                         
		 GOTO Err
		
		END
		update ASSET_WINKGO set booked_status= 'true', campaign_id=@campaign_id where id=@asset_winkgo_id
		SET @RETURN_NO='000' -- SUCCESS                           
		GOTO Err
     END
     ELSE 
     BEGIN
     print('NO ID exists ');
     SET @RETURN_NO='002' -- No Asset ID                          
	 GOTO Err
	 END
     
     --- CHECK ALREADY BOOKED 
     
   
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
	END
