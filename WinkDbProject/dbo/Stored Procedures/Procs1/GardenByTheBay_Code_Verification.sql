-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[GardenByTheBay_Code_Verification]
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
			where staff_code like @redemptionCode and campaign_id = 130)
			BEGIN
				update qr_campaign 
				set redemption_status = '1' , 
				redeemed_on =@current_date,
				redemption_code = @redemptionCode,
				redemption_location = @GPS_location
				where id = @redemptionId
				and redemption_status = '0' 
			
				IF(@@ROWCOUNT>0)
					BEGIN
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
