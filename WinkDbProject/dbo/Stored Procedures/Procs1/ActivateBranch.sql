CREATE PROCEDURE [dbo].[ActivateBranch]
	(@branch_code int
	 )
	
AS
BEGIN
declare @merchantId int

	SELECT @merchantId = merchant_id FROM merchant_partners_address where branch_code = @branch_code

	IF not exists (Select 1 from merchant_partners_address where merchant_id = @merchantId and status = 1)
	BEGIN
		UPDATE merchant_partners SET status = 1 where merchant_id = @merchantId;
		
	END


	Update merchant_partners_address 
	Set status = '1'
	where branch_code = @branch_code;

	UPDATE branch
	SET branch_status = '1', allowed_device = 'Yes'
	where branch_code = @branch_code;

	

END
