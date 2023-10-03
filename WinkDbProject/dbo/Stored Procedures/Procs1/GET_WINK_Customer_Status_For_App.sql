CREATE Procedure [dbo].[GET_WINK_Customer_Status_For_App]
(
  @email varchar(50)
   
)
AS
BEGIN

	declare @customer_email varchar(50)
	Declare @filtering_status varchar(50)
	Declare @customer_id int
	set @customer_email = LTRIM(RTRIM(@email))

	if (@customer_email is null or @customer_email = '')
	begin
		select 0 as response_code , 'Please key in an email' as response_message
		return;
	end

	IF EXISTS (SELECT 1 FROM customer WHERE customer.email = @customer_email AND customer.status='enable')
	BEGIN
		select 1 as response_code , 'Your account is active' as response_message
		return;
	END
	ELSE IF EXISTS (SELECT 1 FROM customer WHERE customer.email = @customer_email AND customer.status='disable')
	BEGIN

	   /* select top 1 @filtering_status=filtering_status  
		 from wink_account_filtering as f,customer as c  where c.customer_id = f.customer_id
		 and c.email =@customer_email
         and c.status ='disable' order by id desc*/

		 print('1')

		 select @customer_id = customer_id from customer WHERE customer.email = @customer_email AND customer.status='disable'

		  print(@customer_id)
		 ------1. CHECK ENQUIRY EMAIL 
		 IF EXISTS (SELECT 1 FROM wink_account_filtering WHERE email_request_status ='Yes' and whatsapp_request_status ='No' and customer_id =@customer_id)
		 BEGIN
		 print('1. CHECK ENQUIRY EMAIL ')
		 select 0 as response_code , 'Enquiry received. Review in progress.' as response_message
		 return;
		 END 
		 -----2. CHECK WHATSAPP MESSAGE
		 ELSE IF EXISTS (SELECT 1 FROM wink_account_filtering WHERE email_request_status ='Yes' 
		 and whatsapp_request_status ='Yes'and customer_id =@customer_id and filtering_status != 'suspension' and filtering_status !='done')
		 BEGIN
		 print('1. CHECK WHATSAPP ')
		 select 0 as response_code , 'Whatsapp received. Review in progress.' as response_message
		 return;
		 END 

		  -----3. CHECK Suspension
		 ELSE IF EXISTS (SELECT 1 FROM wink_account_filtering WHERE email_request_status ='Yes' 
		 and whatsapp_request_status ='Yes'and customer_id =@customer_id and filtering_status = 'suspension' )
		 BEGIN
		  print('1. suspension ')
		 select 0 as response_code , 'Account is suspended' as response_message
		 return;
		 END 

		 -----4. 
		 ELSE 
		 BEGIN

		 select 0 as response_code , 'Your Account is locked. Please send in an email enquiry.' as response_message
		 return;
		 END 
	  
		
	END
	ELSE 
	BEGIN
		select 0 as response_code , 'Email does not exist' as response_message
		return;
	END
END


--select * from wink_account_filtering

