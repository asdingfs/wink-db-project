CREATE Procedure [dbo].[Create_New_MerchantRedemptionOutlets]
(
@outlet_name varchar(150),
@outlet_addresss varchar(150),
@postal_code varchar(150),
@phone varchar (50)
)

AS 
BEGIN
DECLARE @merchant_id int 
DECLARE @max_id int 
DECLARE @current_date datetime
Exec GET_CURRENT_SINGAPORT_DATETIME @current_date output
	BEGIN
		Insert into merchant_redemption_outlets (outlet_name,outlet_address,postal_code,phone,created_at,updated_at)
		values (@outlet_name,@outlet_addresss,@postal_code,@phone,@current_date,@current_date)
		IF(@max_id>0)
					Begin
					Select '1' as success , 'Successfully added' as response_message
					End
				Else 
					Begin
						
						Select '0' as success , 'Fail to insert address' as response_message
					End
	END



	
END
