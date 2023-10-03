CREATE Procedure [dbo].[GET_MerchantPartner_By_MerchantID]
(@outlet_id int )
AS 
BEGIN
Select * from merchant_redemption_outlets where merchant_redemption_outlets.outlet_id = @outlet_id
END
