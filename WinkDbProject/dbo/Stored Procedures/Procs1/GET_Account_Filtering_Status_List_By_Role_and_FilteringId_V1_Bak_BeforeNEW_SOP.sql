Create PROCEDURE [dbo].[GET_Account_Filtering_Status_List_By_Role_and_FilteringId_V1_Bak_BeforeNEW_SOP]
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

		

	IF (@internal_procedure =1  OR @filter_procedure_key ='new')
			BEGIN
			     Print ('1')
				IF(@filter_procedure_key ='pending_remark')
					BEGIN
					  Print ('2')
						IF(@admin_role_id = 4)
						BEGIN
						 SELECT * FROM wink_account_filtering_status_new WHERE internal_procedure =1 
						 and  filtering_status =1
						RETURN
						END
						ELSE IF(@admin_role_id = 1)
						BEGIN
						 SELECT * FROM wink_account_filtering_status_new WHERE internal_procedure =2
						 RETURN
						END
					

					END
				ELSE 
					BEGIN
					  Print ('3')
						SELECT * FROM wink_account_filtering_status_new WHERE internal_procedure =1
						 and  filtering_status =1
						RETURN
					END
			END
	ELSE IF (@filter_procedure_key = 'sop' and @internal_procedure =2)
	BEGIN

		SELECT * FROM wink_account_filtering_status_new WHERE internal_procedure =3 
	END
	ELSE IF (@filter_procedure_key = 'dev_updated' and @internal_procedure =2)
	BEGIN

		SELECT * FROM wink_account_filtering_status_new WHERE filter_procedure_key ='ou2'
	END
		
	ELSE IF (@filter_procedure_key ='review' AND @internal_procedure =3 )
		BEGIN

			SELECT * FROM wink_account_filtering_status_new WHERE internal_procedure =4
		END
			
	ELSE IF (@filter_procedure_key ='ou2')
		BEGIN
						 SELECT * FROM wink_account_filtering_status_new WHERE internal_procedure =2
						 RETURN
		END



END

	--select * from wink_account_filtering_status






--select * from wink_account_filtering_status_new