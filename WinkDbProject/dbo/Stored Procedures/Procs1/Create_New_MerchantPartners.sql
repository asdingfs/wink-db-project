CREATE Procedure [dbo].[Create_New_MerchantPartners]
(
@merchant_name varchar(150),
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
SET @merchant_id =0
Insert into merchant_partners (name,created_at,updated_at,status) values (@merchant_name,@current_date,@current_date,'1')
  SET @merchant_id  =  (SELECT SCOPE_IDENTITY());
          
    IF @merchant_id >0 
		BEGIN 
			IF (@outlet_addresss IS NOT NULL AND @outlet_addresss !='')
			BEGIN
				Insert into merchant_partners_address (merchant_id , outlet_address,postal_code,phone,created_at,updated_at,status)
				values (@merchant_id,@outlet_addresss,@postal_code,@phone,@current_date,@current_date,'1')
				SET @max_id = (SELECT SCOPE_IDENTITY());
				IF(@max_id>0)
					Begin
					Select '1' as success , 'Successfully added' as response_message
					End
				Else 
					Begin
						Delete from merchant_partners where merchant_partners.merchant_id= @merchant_id
						Select '0' as success , 'Fail to insert address' as response_message
					End
		
			END
			ELSE 
				BEGIN
					Select '1' as success , 'Successfully added' as response_message
				END
		END
		
	ELSE
	
		BEGIN
			Select '0' as success , 'Fail to add merchant' as response_message
		END
		
		
		
	
END
