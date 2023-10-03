CREATE PROCEDURE [dbo].[Get_eVoucherDetail_By_VerificationCode_ThirdPartyKey_BranchCode]
(
	@verification_code varchar(50),
	@secret_key varchar(255),
	@branch_code varchar(50)
)
AS
BEGIN

DECLARE @merchant_id int
DECLARE @evoucher_id int
/*------------------------Merchant Authentication---------------------*/

	SET @merchant_id = (Select thirdparty_authentication.merchant_id from thirdparty_authentication where thirdparty_authentication.secret_key =@secret_key and thirdparty_authentication.status_auth=1)
	
	IF @merchant_id IS NOT NULL AND @merchant_id !='' AND @merchant_id !=0
		BEGIN 
		  /* Get eVoucher */
		   SET @evoucher_id =( SELECT 
		    eVoucher_verification.eVoucher_id
		  		     from eVoucher_verification where eVoucher_verification.verification_code =@verification_code
		    AND eVoucher_verification.branch_id =@branch_code)
				
			IF @evoucher_id IS NOT NULL AND @evoucher_id !='' AND @evoucher_id!=0
				BEGIN
					SELECT e.earned_evoucher_id,e.eVoucher_amount,e.used_status,e.expired_date,
					v.branch_id as branch_code,
					
					e.eVoucher_code,1 as success,'Valid merchant key ,branch id and verification code' as response_message
					
					from customer_earned_evouchers As e, eVoucher_verification as v  where 
					e.earned_evoucher_id = v.eVoucher_id
					AND
					e.earned_evoucher_id = @evoucher_id
					AND v.verification_code = @verification_code
				
				END	
			ELSE 
				BEGIN
				 SELECT 0 AS success ,'Invalid varification code or branch id' As response_message
				END
		    
		    
		  
		END
	ELSE 
		BEGIN
			SELECT 0 AS success ,'Invalid merchant key' As response_message
		END 
	
END


 /* SELECT eVoucher_verification.branch_id,
		    eVoucher_verification.created_at,
		    eVoucher_verification.customer_id,
		    eVoucher_verification.eVoucher_code,
		    eVoucher_verification.eVoucher_id,
		    eVoucher_verification.eVoucher_verification_id,
		    eVoucher_verification.valid_till,
		    eVoucher_verification.verification_code,
		    1 as success
		     from eVoucher_verification where eVoucher_verification.verification_code =@verification_code
		    AND eVoucher_verification.branch_id IN (select branch_code from branch where branch.merchant_id =@merchant_id)
		    */
