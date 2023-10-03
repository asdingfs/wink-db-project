CREATE Procedure [dbo].[SPG_Roadshow_Code_Verification]
(
  @redemptionId int,
  @redemptionCode varchar(10),
  @GPS_location varchar(255)
)
AS
BEGIN
	Declare @current_date datetime
	Declare @customer_id int


	Exec GET_CURRENT_SINGAPORT_DATETIME @current_date output

	set @customer_id = (SELECT customer_id from qr_campaign where id = @redemptionId and redemption_status = '0');


	IF(@customer_id !=0)
	BEGIN

		IF EXISTS (select 1 from customer where customer_id = @customer_id and status ='disable' )
		BEGIN
			select 0 as response_code , 'Account locked. Please contact customer service.' as response_message
			Return
		END
		ELSE
		BEGIN
			IF EXISTS (
			select 1 from winktag_redemption_staffs 
			where staff_code like @redemptionCode and campaign_id = 65)
			BEGIN

				declare @pointsValue int = 1000;

				update qr_campaign 
				set redemption_status = '1' , 
				redeemed_on =@current_date,
				redemption_code = @redemptionCode,
				redemption_location = @GPS_location,
				points = @pointsValue
				where id = @redemptionId
				and redemption_status = '0'; 
			
				IF(@@ROWCOUNT>0)
					BEGIN

						IF EXISTS (SELECT 1 FROM CUSTOMER_BALANCE WHERE CUSTOMER_ID =@CUSTOMER_ID)
						BEGIN
							UPDATE CUSTOMER_BALANCE SET TOTAL_POINTS = (SELECT TOTAL_POINTS FROM CUSTOMER_BALANCE WHERE CUSTOMER_ID =@CUSTOMER_ID)+@pointsValue
							WHERE CUSTOMER_ID =@CUSTOMER_ID;
							
						END
						ELSE
						BEGIN
							INSERT INTO customer_balance 
							(customer_id,total_points,used_points,total_winks,used_winks,total_evouchers,total_used_evouchers,total_scans)VALUES
							(@CUSTOMER_ID,@pointsValue,0,0,0,0,0,0) 
							IF NOT(@@ROWCOUNT>0)
							BEGIN
								Select 0 as response_code, 'Insert Fail!' as response_message
								Return
							END
						END

						Select 1 as response_code, 'Redemption successful!' as response_message
						Return
					END
							
			END
			ELSE
			BEGIN
				Select 0 as response_code, 'Invalid code,<br> please try again!' as response_message
				Return
			END			  
				
		END
	END
	ELSE 
	BEGIN
		Select 0 as response_code, 'Invalid customer' as response_message
						Return
	END	
END


