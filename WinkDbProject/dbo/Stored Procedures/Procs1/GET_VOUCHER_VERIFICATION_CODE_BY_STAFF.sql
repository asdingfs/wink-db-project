
CREATE PROC [dbo].[GET_VOUCHER_VERIFICATION_CODE_BY_STAFF]
@staff_tokenid VARCHAR(50)
AS

DECLARE @Staff_ID INT
DECLARE @Branch_ID INT
DECLARE @Branch_CODE INT
DECLARE @VERIFICATION_CODE VARCHAR(8)
DECLARE @VERIFICATION_VALID_TILL DATETIME
DECLARE @VERIFICATION_ID INT
DECLARE @CURRENT_DATETIME DATETIME

BEGIN
	Exec GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUT
	--1) CHECK TOKEN_ID EXISTS OR NOT. IF EXISTS, GET CUTOMER_ID--
	--2) CHECK BRANCH ID EXISTS OR NOT. 
	--3) IF EXISTS BRANCH ID, CHECK EVOUCHER CODE EXISTS OR NOT
	--4) IF EXISTS EVOUCHER CODE, GENERATE VERIFICATION CODE 
	--5) INSERT INTO eVoucher_verification

	--1) CHECK TOKEN_ID EXISTS OR NOT. IF EXISTS, GET CUTOMER_ID--
	IF EXISTS(SELECT * FROM staff WHERE auth_token = @staff_tokenid) --CUSTOMER EXISTS                           
	BEGIN
		SELECT TOP 1 @Staff_ID = staff_id FROM staff WHERE auth_token = @staff_tokenid 
		SELECT @Branch_ID = staff.branch_id FROM staff WHERE staff.staff_id = @Staff_ID
		print(@Branch_ID)
		
		--2) CHECK BRANCH ID EXISTS OR NOT
				
		IF EXISTS(SELECT * FROM BRANCH WHERE branch_id = @Branch_ID and Lower(allowed_device) = 'yes') --BRANCH ID EXISTS
		BEGIN
		      	SELECT @Branch_CODE = branch.branch_code FROM branch WHERE branch.branch_id=@Branch_ID
		      		      	
		      	--SELECT '1' as response_code, 'Success' as response_message, @VERIFICATION_VALID_TILL AS VERIFICATION_VALID_TILL, @VERIFICATION_CODE AS VERIFICATION_CODE
					SELECT eVoucher_verification.eVoucher_verification_id,
					 verification_code,valid_till,
					'1' as response_code
					 FROM eVoucher_verification,customer_earned_evouchers
					 WHERE customer_earned_evouchers.earned_evoucher_id = eVoucher_verification.eVoucher_id
					  AND
					  eVoucher_verification.branch_id=@Branch_CODE
					  
					  AND
					  customer_earned_evouchers.used_status =0
					  
					 ORDER BY eVoucher_verification_id DESC
					 
				RETURN
			
		END
		ELSE
		BEGIN
			SELECT '0' as response_code, 'Branch ID does not exist' as response_message 
			RETURN
		END
		
	END
	ELSE-- CUSTOMER DOES NOT EXISTS
	BEGIN
		SELECT '0' as response_code, 'Staff does not exist' as response_message 
		RETURN
	END
	
END

