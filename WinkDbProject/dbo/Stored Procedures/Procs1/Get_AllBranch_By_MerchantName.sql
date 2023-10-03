CREATE PROCEDURE [dbo].[Get_AllBranch_By_MerchantName]
	(@merchant_name varchar(250))
AS
BEGIN
	
	 Select branch.branch_id,branch.branch_name,branch.branch_code,branch.allowed_device,branch.created_at,
            branch.updated_at,branch.merchant_id,merchant.first_name,merchant.last_name,merchant.status
            From branch,merchant
            Where branch.merchant_id = merchant.merchant_id
            AND (merchant.first_name Like '%'+@merchant_name+'%' OR 
            merchant.last_name Like '%'+@merchant_name+'%')
            Order By branch.branch_id DESC
END

 