CREATE Procedure [dbo].[Update_MerchantRedemptionOutlets_By_OutletID]
(@outlet_id int,
@outlet_name varchar(150),
@outlet_address varchar(150),
@postal_code varchar(150),
@phone varchar (50),
@status varchar(10)

 )
AS 
BEGIN
Update merchant_redemption_outlets 
Set outlet_name = @outlet_name,
outlet_address =@outlet_address,
postal_code =@postal_code,
phone =@phone,
status = @status
where merchant_redemption_outlets.outlet_id = @outlet_id
END
