CREATE PROCEDURE [dbo].[Get_Customer_Earned]
	( 
	 @auth_token varchar(150)
	
	 )
AS
BEGIN
Declare @customer_id int

-- Check account locked
IF EXISTS (select 1 from customer where customer.auth_token = @auth_token and status ='disable')
     BEGIN
   
	 SELECT '2' as response_code, 'Your account is locked. Please contact customer service.' as response_message
	
	RETURN 
	END-- END

---- Get Customer Id

set @customer_id = (select customer_id from customer where customer.auth_token = @auth_token and status ='enable')

		IF (@customer_id is null or @customer_id =0 or @customer_id ='')
		 BEGIN
   
			 SELECT '0' as response_code, 'Customer is not authorized.' as response_message
	
			RETURN 
		 END-- END

		 ELSE
		 BEGIN
		 
		 IF Exists (select 1 from customer_balance where customer_id =@customer_id)
		 BEGIN
		 select b.total_points-b.used_points as balanced_points,

		  b.total_winks-b.used_winks as balanced_winks ,
		  b.total_evouchers - b.total_used_evouchers as balanced_eVoucher ,
		  1 as response_code	  
		  from customer_balance as b where customer_id = @customer_id 
		  Return

		 END
		 ELSE
		 BEGIN
		 print('11')
		  select 0 as balanced_points,

		  0 as balanced_winks ,
		  0 as balanced_eVoucher ,
		  1 as response_code	  
		 
		  Return

		 END
		 

		  
		 END


 


END


