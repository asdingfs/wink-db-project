create procedure GET_eVoucherConvertion_Partners_Image_And_Name

AS
BEGIN

select * from WINK_eVoucherConversion_Partner where partner_status =1

END