
CREATE PROCEDURE [dbo].[Insert_Wink_Gate_Earned_Points]
	(
	  @customer_id int,
	  @campaign_id int,
	  @wink_gate_asset_id int,
	  @total_points int,
	  @gps_location varchar(100),
	  @business_date datetime
	  )
	  
AS
BEGIN
	DECLARE @CURRENT_DATETIME datetime
	
	EXEC dbo.GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME output
	
	

    IF NOT EXISTS (select 1 from nonstop_net_canid_earned_points where customer_id=@customer_id and campaign_id=@campaign_id and wink_gate_asset_id=@wink_gate_asset_id 
					and CAST (business_date as DATE) = CAST (@CURRENT_DATETIME as DATE))
	BEGIN
		DECLARE @counter int=1;
		
		WHILE @counter<=@total_points
			BEGIN
				insert into nonstop_net_canid_earned_points (customer_id ,created_at,business_date,can_id,card_type,total_tabs,total_points,updated_at,campaign_id,wink_gate_asset_id)
					values (@customer_id,@CURRENT_DATETIME,@business_date,'','11',1,1,@CURRENT_DATETIME,@campaign_id,@wink_gate_asset_id)
				set @counter = @counter + 1
			END
		IF @@ROWCOUNT>0
		BEGIN
			select '1' as response_code , 'Successfully inserted' as response_message
			RETURN
		END
    --(can_id,business_date,total_tabs,total_points,created_at,customer_id)
    --VALUES (@can_id,@business_date,@total_tabs,@total_points,@created_at,@customer_id)
	END
	select '0' as response_code , 'Data inserted already for today' as response_message

END