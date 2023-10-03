CREATE PROCEDURE Get_AllCustomer_WithFilter
	(@customer_name varchar(150),
	 @email varchar(150))
	 
AS
BEGIN
     IF (@customer_name IS NOT NULL AND  @customer_name !='' and @email IS NOT NULL AND  @email !='')
     BEGIN
     print('filter')
	Select * from customer 
	where Lower(customer.first_name +' '+ customer.last_name) LIKE Lower('%' + @customer_name +'%')
	AND 
	Lower(customer.email) LIKE Lower('%'+ @email +'%') order by customer.customer_id DESC
	RETURN
	END
	ELSE IF @customer_name IS NOT NULL AND @customer_name !=''
		BEGIN
			print ('Name')
			Select * from customer where 
			Lower(customer.first_name +' '+ customer.last_name) LIKE Lower('%' + @customer_name +'%')
			order by customer.customer_id DESC
			Return
		END
	ELSE IF @email IS NOT NULL AND @email !=''
		BEGIN
			Select * from customer where 
			Lower(customer.email) LIKE Lower('%'+ @email +'%') order by customer.customer_id DESC
			Return
		END
	ELSE
		BEGIN
		print('ALL')
		Select * from customer order by customer.customer_id DESC
		Return
		END
		
		
	
END
