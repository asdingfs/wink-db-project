
Create PROCEDURE [dbo].[Get_AllUser_Detail_With_Status_Subscribe2]
	 (@email varchar(150),
	  @name varchar (200),
	  @status varchar(20),
	  @created_from varchar(50),
	  @created_to varchar(50),
	  @ip_address varchar(100),
	  @customer_id varchar(100),
	  @subscribe_status varchar(10)
	  )
AS
BEGIN


IF OBJECT_ID('tempdb..#tmpCustomerDetail') IS NOT NULL     
Drop table #tmpCustomerDetail
CREATE TABLE #tmpCustomerDetail    
(     auth_token varchar(150),
	  created_at varchar(50),
	  customer_id int,
	  date_of_birth VARCHAR(100),
      email varchar(150),
      first_name varchar(50),
      last_name varchar(50),
      password varchar(100),
      gender varchar(10),
      status varchar(20),
	  group_id varchar(10),
	  phone_no varchar(10),
	  subscribe_status varchar(10),	  
	  ip_address varchar(100)
	  
	  
	  )  
	  

	-- Filter Created At
	
	If (@created_from IS NOT NULL AND @created_from !='' AND @created_to IS NOT NULL AND @created_to !='')
		BEGIN
		;WITH customer_action_log_temp AS
					(
					   SELECT *,
							 ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY created_at DESC) AS rn
					   FROM customer_action_log
					)
		Insert into #tmpCustomerDetail
					
						Select customer.auth_token,customer.created_at,
						customer.customer_id,customer.date_of_birth,
						customer.email,
						customer.first_name,
						customer.last_name,
						customer.password,
						customer.gender,
						customer.status,
						customer.group_id
						
						
						
						
							,customer.phone_no
						    ,customer.subscribe_status
						
						
						
						
						,(select Top 1 customer_action_log_temp.ip_address from customer_action_log_temp where customer_action_log_temp.customer_id = customer.customer_id order by customer_action_log_temp.created_at desc) as ip_address
						
						
						from customer 
						where Lower(customer.first_name +' '+ customer.last_name) LIKE '%'+Lower(@name)+'%' AND Lower(customer.email) LIKE '%'+@email+'%' 
						
						
						and status Like '%'+@status+'%'
						and subscribe_status Like '%'+@subscribe_status+'%'
						and CAST(customer.created_at As DATE) >= CAST(@created_from as date) AND CAST(customer.created_at As DATE) <= CAST(@created_to as date)
						order by customer.customer_id DESC
		END
		
		ELSE
		
		BEGIN
		;WITH customer_action_log_temp AS
					(
					   SELECT *,
							 ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY created_at DESC) AS rn
					   FROM customer_action_log
					)
		Insert into #tmpCustomerDetail
					
						Select customer.auth_token,customer.created_at,customer.customer_id,customer.date_of_birth,customer.email,customer.first_name,customer.last_name,customer.password,customer.gender,
						customer.status,customer.group_id
						
						
						
						
							,customer.phone_no
						    ,customer.subscribe_status
																	
						
						,(select Top 1 customer_action_log_temp.ip_address from customer_action_log_temp where customer_action_log_temp.customer_id = customer.customer_id order by customer_action_log_temp.created_at desc) as ip_address
						
						
						from customer where Lower(customer.first_name +' '+ customer.last_name) LIKE '%'+Lower(@name)+'%' AND Lower(customer.email) LIKE '%'+@email+'%' 
						
						
						and status Like '%'+@status+'%'
						and subscribe_status Like '%'+@subscribe_status+'%'
						order by customer.customer_id DESC
		
		END
				
				IF(@ip_address IS NOT NULL AND @ip_address !='')
				BEGIN									
											
					Select * from #tmpCustomerDetail 
					WHERE #tmpCustomerDetail.ip_address Like @ip_address +'%'
					order by #tmpCustomerDetail.customer_id desc
					RETURN
				END
				ELSE
				
				IF(@customer_id IS NOT NULL AND @customer_id !='')
				BEGIN
							Select * from #tmpCustomerDetail 
							WHERE #tmpCustomerDetail.customer_id = @customer_id 
							order by #tmpCustomerDetail.customer_id desc
							RETURN
				END
				
				ELSE
				BEGIN
				
				Select * from #tmpCustomerDetail
				order by #tmpCustomerDetail.customer_id desc
				RETURN 
				END
					
					

	 
	
END















