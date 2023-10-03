CREATE PROCEDURE [dbo].[GET_Account_Filtering_Status_List_By_Role_and_FilteringId_V1]
	 (@admin_email varchar(100),
	  @filtering_id int
		  )
AS
BEGIN
Declare @admin_role_id int,
		@internal_procedure varchar(10),
		@filtering_status_key varchar(50),
		@filter_procedure_key varchar(100)

		select @admin_role_id = admin_user.admin_role_id from admin_user where email = @admin_email

		select @filter_procedure_key =n.filter_procedure_key, @internal_procedure = n.internal_procedure,  
		@filtering_status_key = n.filtering_status_key
		from wink_account_filtering as s ,wink_account_filtering_status_new as n 
		where s.filtering_status= n.filtering_status_key
		and s.id =@filtering_id

		--- OPS ROLE
		 IF (@admin_role_id = 4)
		 BEGIN
			  SELECT * FROM wink_account_filtering_status_new WHERE (internal_procedure =1 or internal_procedure =4
			  or internal_procedure =6 or id =10 or id =29)
			  and  filtering_status =1
			  and filter_procedure_name !='All'
			  and id !=23
			  and filtering_status_key !='ou2'
			  order by internal_procedure 
			  RETURN

		 END
         ELSE IF(@admin_role_id =1)
		 BEGIN

		   SELECT * FROM wink_account_filtering_status_new WHERE internal_procedure =2 
			  and  filtering_status =1
			  RETURN

		 END
		 ELSE 
		 BEGIN

			  SELECT * FROM wink_account_filtering_status_new WHERE internal_procedure =4
			  and  filtering_status =1

		 END
		
		 






END


--select * from wink_account_filtering_status_new 

--update wink_account_filtering_status_new set internal_procedure = 2 where id =10