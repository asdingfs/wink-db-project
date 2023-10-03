CREATE PROCEDURE [dbo].[DisableBranch]
	(@branch_code int
	 )
	
AS
BEGIN

declare @merchantId int
	
	Update merchant_partners_address 
	Set status = '0'
	where branch_code = @branch_code;

	UPDATE branch
	SET branch_status = '0', allowed_device = 'No'
	where branch_code = @branch_code;

    SELECT @merchantId = merchant_id FROM merchant_partners_address where branch_code = @branch_code

	IF not exists (Select 1 from merchant_partners_address where merchant_id = @merchantId and status = 1)
	BEGIN
		UPDATE merchant_partners SET status = 0 where merchant_id = @merchantId;
		
	END
END
