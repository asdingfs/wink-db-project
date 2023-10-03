CREATE PROCEDURE [dbo].[GetBranch_Info_ByStaffTokenId]
	(@staff_tokenid varchar(100))
AS
BEGIN
DECLARE @Staff_ID INT
DECLARE @Branch_ID INT
IF EXISTS(SELECT * FROM staff WHERE auth_token = @staff_tokenid) --CUSTOMER EXISTS                           
	BEGIN
		SELECT TOP 1 @Staff_ID = staff_id FROM staff WHERE auth_token = @staff_tokenid 
		SELECT staff.staff_id,staff.branch_id,branch.allowed_device,branch.branch_code,
		branch.branch_name,branch.allowed_device,branch.merchant_id,merchant.first_name as m_firstName,
		merchant.last_name as m_lastName
		From staff,branch,merchant
		Where staff.branch_id = branch.branch_id
		And merchant.merchant_id = branch.merchant_id
		And staff.staff_id =@Staff_ID
		
	END	
END
