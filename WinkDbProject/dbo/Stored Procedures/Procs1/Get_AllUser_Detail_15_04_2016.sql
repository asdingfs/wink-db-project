
CREATE PROCEDURE [dbo].[Get_AllUser_Detail_15_04_2016]
	 (@email varchar(150),
	  @name varchar (200)
	 -- @status varchar(20)
	 -- @created_from varchar(50),
	 -- @created_to varchar(50),
	 -- @ip_address varchar(100),
	 -- @customer_id varchar(100)
	  )
AS
BEGIN

	-- Filter Created At
	
	DECLARE  
	@created_from varchar(50),
	@created_to varchar(50),
	@ip_address varchar(100),
	@customer_id varchar(100),
	@status varchar(100)
	select * from customer
/*	If (@created_from IS NOT NULL AND @created_from !='' AND @created_to IS NOT NULL AND @created_to !='')
		BEGIN
		
				Select customer.auth_token,customer.created_at,customer.customer_id,customer.date_of_birth,customer.email,customer.first_name,customer.last_name,customer.password,customer.gender,
				customer.status,customer.group_id,
				
				(select Top 1 customer_action_log.ip_address from customer_action_log where customer_action_log.customer_id = customer.customer_id and ip_address LIKE '%'+ @ip_address +'%' order by customer_action_log.id desc) as ip_address
				
				
				from customer where Lower(customer.first_name +' '+ customer.last_name) LIKE '%'+Lower(@name)+'%' AND Lower(customer.email) LIKE '%'+@email+'%' 
				
				and customer.customer_id Like '%'+@customer_id +'%'
				and status Like '%'+@status+'%'
				and CAST(customer.created_at As DATE) >= CAST(@created_from as date) AND CAST(customer.created_at As DATE) <= CAST(@created_to as date)
				order by customer.customer_id DESC
		END
	 ELSE 
	 
	 BEGIN
		
				Select customer.auth_token,customer.created_at,customer.customer_id,customer.date_of_birth,customer.email,customer.first_name,customer.last_name,customer.password,customer.gender,
				customer.status,customer.group_id,
				
				(select Top 1 customer_action_log.ip_address from customer_action_log where customer_action_log.customer_id = customer.customer_id and ip_address LIKE '%'+ @ip_address +'%' order by customer_action_log.id desc) as ip_address
				
				
				from customer where Lower(customer.first_name +' '+ customer.last_name) LIKE '%'+Lower(@name)+'%' AND Lower(customer.email) LIKE '%'+@email+'%' 
				
				and customer.customer_id Like '%'+@customer_id +'%'
				and status Like '%'+@status+'%'
				--and CAST(@created_from as date) >= customer.created_at and CAST(@created_to as date)<=customer.created_at
				order by customer.customer_id DESC
		END
	 
	
	
	*/
	
/*IF OBJECT_ID('tempdb..#tmpCustomerDetail') IS NOT NULL     
Drop table #tmpCustomerDetail
CREATE TABLE #tmpCustomerDetail    
(    
	  auth_token varchar(150),
	  created_at varchar(50),
	  customer_id int,
	  date_of_birth DateTime,
      email varchar(150),
      first_name varchar(50),
      last_name varchar(50),
      password varchar(100),
      gender varchar(10),
      status varchar(20),
	  group_id varchar(10),
	  
	  ip_address varchar(100))   
 
   -- Filter IP Address
  
	IF (@ip_address !='' AND @ip_address IS NOT NULL)
	   
			BEGIN
			Insert into #tmpCustomerDetail
				Select customer.auth_token,customer.created_at,customer.customer_id,customer.date_of_birth,customer.email,customer.first_name,customer.last_name,customer.password,customer.gender,
				customer.status,customer.group_id,
				
				(select Top 1 customer_action_log.ip_address from customer_action_log where customer_action_log.customer_id = customer.customer_id and ip_address = @ip_address order by customer_action_log.id desc) as ip_address
				
				
				from customer where Lower(customer.first_name +' '+ customer.last_name) LIKE '%'+Lower(@name)+'%' AND Lower(customer.email) LIKE '%'+@email+'%' order by customer.customer_id DESC
			END

	ELSE 
			BEGIN
				Insert into #tmpCustomerDetail
				Select customer.auth_token,customer.created_at,customer.customer_id,customer.date_of_birth,customer.email,customer.first_name,customer.last_name,customer.password,customer.gender,
				customer.status,customer.group_id,
				
				(select Top 1 customer_action_log.ip_address from customer_action_log where customer_action_log.customer_id = customer.customer_id  order by customer_action_log.id desc) as ip_address
						
				from customer where Lower(customer.first_name +' '+ customer.last_name) LIKE '%'+Lower(@name)+'%' AND Lower(customer.email) LIKE '%'+@email+'%' order by customer.customer_id DESC
			END
*/
END

