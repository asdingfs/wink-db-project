CREATE PROCEDURE GetAllStaffDetail

AS
BEGIN
	Select staff.staff_id ,staff.first_name As staff_fn,
    staff.last_name As staff_ln, staff.email,
    staff.created_at,
    merchant.first_name As merchant_fn, merchant.last_name As merchant_ln, merchant.merchant_id,
    branch.branch_name,branch.branch_code
    From staff,merchant,branch
    Where staff.branch_id = branch.branch_id AND
    branch.merchant_id = merchant.merchant_id 
    Order By staff.staff_id DESC
END
