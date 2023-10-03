
CREATE PROCEDURE [dbo].[Get_AllUser_Detail_With_Status]
	 (@email varchar(150),
	  @name varchar (200),
	  @status varchar(20),
	  @created_from varchar(50),
	  @created_to varchar(50),
	  @ip_address varchar(100),
	  @customer_id varchar(100)
	  )
AS
BEGIN


IF OBJECT_ID('tempdb..#tmpCustomerDetail') IS NOT NULL     
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
	-- Filter Created At
	
	If (@created_from IS NOT NULL AND @created_from !='' AND @created_to IS NOT NULL AND @created_to !='')
		BEGIN
		
				IF(@ip_address IS NOT NULL AND @ip_address !='')
				BEGIN
					/*Select customer.auth_token,customer.created_at,customer.customer_id,customer.date_of_birth,customer.email,customer.first_name,customer.last_name,customer.password,customer.gender,
					customer.status,customer.group_id,customer_action_log.ip_address
																				
					from customer JOIN customer_action_log
				
										
					ON customer_action_log.customer_id = customer.customer_id
					
					AND ip_address LIKE  @ip_address +'%'
										
					where 
					Lower(customer.first_name +' '+ customer.last_name) LIKE '%'+Lower(@name)+'%' AND Lower(customer.email) LIKE '%'+@email+'%' 
					
					and customer.customer_id Like '%'+@customer_id +'%'
					and status Like '%'+@status+'%'
					and CAST(customer.created_at As DATE) >= CAST(@created_from as date) AND CAST(customer.created_at As DATE) <= CAST(@created_to as date)
					
					order by customer.customer_id DESC*/
					
					Insert into #tmpCustomerDetail
					
					Select customer.auth_token,customer.created_at,customer.customer_id,customer.date_of_birth,customer.email,customer.first_name,customer.last_name,customer.password,customer.gender,
					customer.status,customer.group_id,
					
					(select Top 1 customer_action_log.ip_address from customer_action_log where customer_action_log.customer_id = customer.customer_id  order by customer_action_log.id desc) as ip_address
					
					
					from customer where Lower(customer.first_name +' '+ customer.last_name) LIKE '%'+Lower(@name)+'%' AND Lower(customer.email) LIKE '%'+@email+'%' 
					
					and customer.customer_id Like @customer_id +'%'
					and status Like '%'+@status+'%'
					and CAST(customer.created_at As DATE) >= CAST(@created_from as date) AND CAST(customer.created_at As DATE) <= CAST(@created_to as date)
					order by customer.customer_id DESC
					
					
					Select * from #tmpCustomerDetail 
					WHERE #tmpCustomerDetail.ip_address Like @ip_address +'%'
					
				END
				ELSE
					BEGIN
					
					Select  customer.auth_token,customer.created_at,customer.customer_id,customer.date_of_birth,customer.email,customer.first_name,customer.last_name,customer.password,customer.gender,
					customer.status,customer.group_id,
					
					(select Top 1 customer_action_log.ip_address from customer_action_log where customer_action_log.customer_id = customer.customer_id  order by customer_action_log.id desc) as ip_address
					
					
					from customer where Lower(customer.first_name +' '+ customer.last_name) LIKE '%'+Lower(@name)+'%' AND Lower(customer.email) LIKE '%'+@email+'%' 
					
					and customer.customer_id Like @customer_id +'%'
					and status Like '%'+@status+'%'
					and CAST(customer.created_at As DATE) >= CAST(@created_from as date) AND CAST(customer.created_at As DATE) <= CAST(@created_to as date)
					order by customer.customer_id DESC
					
					END
		END
	 ELSE 
	 
	 BEGIN
		
				IF(@ip_address IS NOT NULL AND @ip_address !='')
				BEGIN
					Insert into #tmpCustomerDetail
					
					Select customer.auth_token,customer.created_at,customer.customer_id,customer.date_of_birth,customer.email,customer.first_name,customer.last_name,customer.password,customer.gender,
					customer.status,customer.group_id,
					
					(select Top 1 customer_action_log.ip_address from customer_action_log where customer_action_log.customer_id = customer.customer_id  order by customer_action_log.id desc) as ip_address
					
					
					from customer where Lower(customer.first_name +' '+ customer.last_name) LIKE '%'+Lower(@name)+'%' AND Lower(customer.email) LIKE '%'+@email+'%' 
					
					and customer.customer_id Like @customer_id +'%'
					and status Like '%'+@status+'%'
					--and CAST(customer.created_at As DATE) >= CAST(@created_from as date) AND CAST(customer.created_at As DATE) <= CAST(@created_to as date)
					order by customer.customer_id DESC
					
					
					Select * from #tmpCustomerDetail 
					WHERE #tmpCustomerDetail.ip_address Like @ip_address +'%'
				END
				
				ELSE
					BEGIN
					
					;WITH customer_action_log_temp AS
					(
					   SELECT *,
							 ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY created_at DESC) AS rn
					   FROM customer_action_log
					)
					
					Select customer.auth_token,customer.created_at,customer.customer_id,customer.date_of_birth,customer.email,customer.first_name,customer.last_name,customer.password,customer.gender,
					customer.status,customer.group_id,customer_action_log_temp.ip_address as ip_address
					
					FROM customer left join customer_action_log_temp on
					customer.customer_id = customer_action_log_temp.customer_id and rn = 1
					where Lower(customer.first_name +' '+ customer.last_name) LIKE '%'+Lower(@name)+'%' AND Lower(customer.email) LIKE '%'+@email+'%' 
					
					and customer.customer_id Like @customer_id +'%'
					and status Like '%'+@status+'%'
					--and CAST(customer.created_at As DATE) >= CAST(@created_from as date) AND CAST(customer.created_at As DATE) <= CAST(@created_to as date)
					order by customer.customer_id DESC
					
					END
		END
	 
	
END




