
CREATE PROCEDURE [dbo].[GET_Account_Filtering_Status_List_By_Role]
	 (@admin_email varchar(100)
	  )
AS
BEGIN

Declare @admin_role_id int 

select @admin_role_id = admin_user.admin_role_id from admin_user where email = @admin_email

IF (@admin_role_id != 0 )
	BEGIN
		SELECT * FROM wink_account_filtering_status AS S ,
		wink_account_filtering_status_role AS R
		WHERE S.id = R.filtering_id
		AND R.role_id = @admin_role_id
		ORDER BY filtering_status_name

	END 

	--select * from wink_account_filtering_status




END
