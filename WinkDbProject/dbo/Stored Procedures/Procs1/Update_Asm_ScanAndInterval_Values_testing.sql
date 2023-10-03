CREATE PROCEDURE [dbo].[Update_Asm_ScanAndInterval_Values_testing]
(	
	@asset_type_management_id int,
	@scan_value Decimal(5,2),
	@scan_interval Decimal(5,2),
	@special_campagin varchar(100),
	@scan_start_date varchar(100),
	@scan_end_date varchar(100),
	@asset_status varchar(10),
	@asset_code varchar(100),
	@asset_name varchar(100),
	@qr_code_value varchar(100),
	@admin_email varchar(50)
)
	 
AS
BEGIN
	-- Check Special Campaign 
	
	DECLARE @valid_to_update varchar(10)
	DECLARE @current_date datetime
	DECLARE @customer_scan_startdate datetime
	DECLARE @customer_last_scandate datetime
	DECLARE @wink_asset_category varchar(10)

	DECLARE @old_special_campaign varchar(10)
	DECLARE @old_scan_value int
	DECLARE @old_interval decimal(10, 2)
	DECLARE @old_scan_startdate datetime
	DECLARE @old_scan_enddate datetime
	DECLARE @old_wink_asset_category varchar(10)
	DECLARE @old_updated_at datetime

	SET @valid_to_update =1

	IF(@asset_status='' OR @asset_status is null)
	BEGIN
		SET @asset_status =1;
	End

	IF(LOWER(@special_campagin) ='yes')
	BEGIN
		SET @wink_asset_category = 'event';
	END
	ELSE IF(LOWER(@special_campagin) ='no')
	BEGIN
		SET @wink_asset_category = 'global';
	END

	PRINT ('@wink_asset_category');
	PRINT (@wink_asset_category);

	SELECT @old_special_campaign = special_campaign,
	@old_scan_value = scan_value,
	@old_interval = scan_interval,
	@old_scan_startdate=scan_start_date,
	@old_scan_enddate =scan_end_date,
	@old_wink_asset_category = wink_asset_category,
	@old_updated_at = updated_at
	FROM asset_type_management 
	WHERE asset_type_management.asset_type_management_id = @asset_type_management_id

	print ('@old_scan_startdate')

	print (@old_scan_startdate)
	print ('@old_scan_enddate')
	print (@old_scan_enddate)

	print (@old_special_campaign)

	EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date output

	IF(@scan_end_date is not null AND @scan_start_date is not null AND @scan_start_date !='' AND @scan_end_date!='')
	BEGIN
    
		IF Exists (SELECT 1 FROM asset_management_booking AS b 
		WHERE b.asset_type_management_id = @asset_type_management_id	
		AND booked_status ='true' 
		AND (
		(Cast(@scan_start_date AS DATE ) Between CAST(b.start_date AS DATE) AND CAST(b.end_date AS DATE)) 
		OR 
		(Cast(@scan_end_date AS DATE ) Between CAST(b.start_date AS DATE) AND CAST(b.end_date AS DATE))
		))
		BEGIN
			SET @valid_to_update =0;
		END


		print(1)
		IF Exists (SELECT 1 FROM customer_earned_points WHERE qr_code=(SELECT qr_code_value FROM asset_type_management WHERE asset_type_management.asset_type_management_id = @asset_type_management_id
		AND campaign_booking_id =0
		))
		BEGIN
			print(2)
			SELECT @customer_scan_startdate= CAST(created_at AS DATE) FROM customer_earned_points WHERE qr_code=
			(SELECT qr_code_value FROM asset_type_management WHERE asset_type_management.asset_type_management_id = @asset_type_management_id
			)
			AND campaign_booking_id =0
	
			SELECT @customer_last_scandate= 
			CAST(created_at AS DATE) FROM customer_earned_points WHERE qr_code=
			(SELECT qr_code_value FROM asset_type_management WHERE asset_type_management.asset_type_management_id = @asset_type_management_id)
			AND campaign_booking_id =0
			order by created_at desc
	
			print('@customer_scan_startdate')
			print(@customer_scan_startdate)
	
			print('@customer_last_scandate')
			print(@customer_scan_startdate)
	
			IF(@old_scan_startdate !='' AND @old_scan_enddate !='')
			BEGIN
				print(3)
				BEGIN
			
					IF(cast(@scan_start_date AS DATE) != CAST(@old_scan_startdate AS DATE))
					BEGIN
						Print(4)
						if(cast(@scan_start_date AS DATE) != CAST (@customer_scan_startdate AS DATE) AND
						cast(@scan_start_date AS DATE) > CAST (@customer_scan_startdate AS DATE)
						)
						BEGIN
							print(5)
							SET @valid_to_update =0
						End
					END

					IF(cast(@scan_end_date AS DATE) != CAST (@old_scan_enddate AS DATE))
					BEGIN
						print (6)
						IF( CAST(@scan_end_date AS DATE) < CAST(@current_date AS DATE) AND CAST(@scan_end_date AS DATE) !=  CAST (@customer_last_scandate AS DATE))
						BEGIN
							Print (7)
							SET @valid_to_update =0
						End
					END
		
				END
			END
			ELSE 
			BEGIN
				IF(cast(@scan_start_date AS DATE) != CAST (@customer_scan_startdate AS DATE) AND
				cast(@scan_start_date AS DATE) > CAST (@customer_scan_startdate AS DATE)
				)
				BEGIN
					SET @valid_to_update =0
				End
	          
				IF( CAST(@scan_end_date AS DATE) < CAST(@current_date AS DATE) AND CAST(@scan_end_date AS DATE) !=  CAST (@customer_last_scandate AS DATE))
				BEGIN
					SET @valid_to_update =0
				End
			END
		END
	END
	ELSE 
	BEGIN
		SET @scan_start_date = NULL
		SET @scan_end_date = NULL
	End

	-- Check scan end date and scan start date
	IF (@valid_to_update =1)
	BEGIN
		Update asset_type_management 
		SET scan_value = @scan_value,
		scan_interval = @scan_interval,
		special_campaign = @special_campagin,
		wink_asset_category = @wink_asset_category,
		scan_start_date = @scan_start_date,
		scan_end_date = @scan_end_date,
		asset_status = @asset_status,
		updated_at = @current_date
		WHERE asset_type_management.asset_type_management_id = @asset_type_management_id
                           
		IF(@@ROWCOUNT>0)
		BEGIN
			--- Call QR Asset000000 Log Storeprocedure Function 
			DECLARE @result int
			DECLARE @action_object varchar(10) ='QR Asset'
			DECLARE @action_type varchar(10) ='Edit'

			EXEC CreateQRAssetLog
			@asset_type_management_id,
			@old_special_campaign,
			@old_scan_value,
			@old_interval,
			@old_scan_startdate,
			@old_scan_enddate,
			@old_wink_asset_category,
			@admin_email,
			@action_object,
			@action_type,
			@result output ;
			if(@result=2)
			BEGIN
				UPDATE asset_type_management 
				SET special_campaign = @old_special_campaign,
				scan_value = @old_scan_value,
				scan_interval = @old_interval,
				scan_start_date = @old_scan_startdate,
				scan_end_date = @old_scan_enddate,
				wink_asset_category = @old_wink_asset_category,
				updated_at = @old_updated_at 
				WHERE asset_type_management_id =@asset_type_management_id;

				SELECT 0 as success, 'Failed to save' as response_message 
				RETURN
			END
			ELSE		
			BEGIN
				SELECT 1 AS success , 'Successfully saved' AS response_message
				RETURN
			END
		END
        ELSE
		BEGIN
			SELECT 0 AS success , 'Failed to save' AS response_message
		END
	END
	ELSE
	BEGIN
		SELECT 0 AS success , 'Failed to save' AS response_message
	END
END

