CREATE PROCEDURE [dbo].[DisableAsmbookingAndLinkToCampaignId]
	(@booking_id int,
	 @campaign_id int
	 )
 
AS
BEGIN

Declare @merchant_id int
DECLARE @CURRENT_DATE DATETIME

EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATE OUTPUT

	IF EXISTS (SELECT * FROM asset_management_booking WHERE asset_management_booking.booking_id = @booking_id)

	BEGIN 

		Update asset_management_booking set 
		booked_status = 'False',
		updated_at = @CURRENT_DATE
		Where booking_id = @booking_id
		
		IF(@@ROWCOUNT>0 AND @campaign_id >0)
		
			BEGIN
			IF EXISTS (SELECT * FROM campaign WHERE campaign.campaign_id =@campaign_id)
				BEGIN 

				Set @merchant_id = (Select merchant_id from campaign
				where campaign.campaign_id = @campaign_id)

	CREATE TABLE #tempTable(
	[booking_id] [int]  NOT NULL,
	[campaign_id] [int] NOT NULL Default(0),
	[asset_type_management_id] [int] NOT NULL,
	[scan_value] [int] NOT NULL,
	[scan_interval] [float] NOT NULL,
	[start_date] [datetime] NOT NULL,
	[end_date] [datetime] NOT NULL,
	[created_at] [datetime] NULL,
	[updated_at] [datetime] NULL,
	[merchant_id] [int] NULL,
	[station_id] [int] NULL,
	[station_code] [varchar](150) NULL,
	[asset_type_name] [varchar](100) NULL,
	[asset_type_code] [varchar](100) NULL,
	[qr_code_value] [varchar](200) NULL,
	[station_group_id] [int] NULL,
	[booked_status] [varchar](100) NOT NULL)
	
	

	INSERT INTO #tempTable
           ([booking_id]
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
           ,[booked_status])
		Select asm.booking_id,asm.asset_type_management_id,asm.scan_value,asm.scan_interval,
		asm.start_date,asm.end_date,GETDATE(),
		GETDATE(),asm.merchant_id,asm.station_id,asm.station_code,asm.asset_type_name,asm.asset_type_code,
		asm.qr_code_value,asm.station_group_id,asm.booked_status
		From asset_management_booking as asm
		Where asm.booking_id = @booking_id;

		Update #tempTable set campaign_id =@campaign_id , merchant_id = @merchant_id,booked_status ='True'
		Where booking_id = @booking_id;

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
           ,[booked_status])
		Select tmp.campaign_id,tmp.asset_type_management_id,tmp.scan_value,tmp.scan_interval,
		tmp.start_date,tmp.end_date,@CURRENT_DATE,
		@CURRENT_DATE,tmp.merchant_id,tmp.station_id,tmp.station_code,tmp.asset_type_name,tmp.asset_type_code,
		tmp.qr_code_value,tmp.station_group_id,tmp.booked_status
		From #tempTable as tmp
		Where tmp.booking_id = @booking_id;

		IF(@@ROWCOUNT>0)
		BEGIN
		Delete #tempTable;
		END

	END

			
			END


	END
	
END
