
CREATE PROC GAME_GET_VERIFICATION_DETAILS
(
@verification_code VARCHAR(50),
@staff_tokenid VARCHAR(50)
)
AS

DECLARE @Staff_ID INT  
DECLARE @Branch_ID INT 
DECLARE @eVoucherCode VARCHAR(50)
DECLARE @eVoucherValue VARCHAR(50)='0.00'
DECLARE @merchant_name VARCHAR(50)
DECLARE @branch_name VARCHAR(50)

BEGIN
 
	IF EXISTS(SELECT * FROM staff WHERE auth_token = @staff_tokenid) --CUSTOMER EXISTS                             
	BEGIN  
	
		IF EXISTS (SELECT * FROM Game_eVoucher_verification WHERE verification_code = @verification_code)
		BEGIN
			SET @eVoucherCode = (SELECT eVoucher_code FROM Game_eVoucher_verification WHERE verification_code = @verification_code)
			
			SET @Staff_ID = (SELECT TOP 1 staff_id FROM staff WHERE auth_token = @staff_tokenid)
			
			SET @merchant_name = (SELECT merchant.first_name + ' '+merchant.last_name From staff,branch,merchant Where staff.branch_id = branch.branch_id And merchant.merchant_id = branch.merchant_id  And staff.staff_id =@Staff_ID)
			
			SET @branch_name = (SELECT branch.branch_name From staff,branch,merchant Where staff.branch_id = branch.branch_id And merchant.merchant_id = branch.merchant_id  And staff.staff_id =@Staff_ID)
			
			
			SELECT '1' AS response_code, 'Success' AS response_message,@verification_code as verification_code,@eVoucherCode as eVoucherCode,@eVoucherValue as eVoucherValue,@merchant_name as merchant_name,@branch_name as branch_name
			RETURN;
		END
	END 
	ELSE
	BEGIN
		SELECT '0' AS response_code, 'Invalid Staff' AS response_message
		RETURN;
	END
END