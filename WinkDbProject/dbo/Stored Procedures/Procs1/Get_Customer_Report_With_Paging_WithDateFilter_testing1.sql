 CREATE proc [dbo].[Get_Customer_Report_With_Paging_WithDateFilter_testing1]
 ( @wid varchar(50), 
   @customer_id INT,
   @customer_name varchar(150),      
   @customer_email varchar(150),
   @ip_address varchar(50),
   @ip_scanned varchar(30),
   @group_id varchar(10)
 ) as
 Begin
 	Declare @CURRENT_DATETIME Datetime      
	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUTPUT   
	IF(@wid is null or @wid = '')
	BEGIN
		SET @wid = null;
	END
	IF(@customer_name is null or @customer_name = '')
	BEGIN
		SET @customer_name = null;
	END

	IF(@customer_email is null or @customer_email = '')
	BEGIN
		SET @customer_email = null;
	END
	IF(@ip_address is null or @ip_address ='')
	BEGIN 
		SET @ip_address = null;
	END
	IF(@ip_scanned is null or @ip_scanned ='')
	BEGIN 
		SET @ip_scanned = null;
	END
	
Declare @imob_group_id1 int ;
	Declare @imob_group_id2 int ;
	Declare @imob_group_id3 int ;
	Declare @imob_group_id4 int ;
	Declare @imob_group_id5 int ;
	Declare @imob_group_id6 int ;

	set @imob_group_id1 =@group_id;
	set @imob_group_id2 =@group_id;
	set @imob_group_id3 =@group_id;
	set @imob_group_id4 =@group_id;
	set @imob_group_id5 =@group_id;
	set @imob_group_id6 =@group_id;

	if(@group_id is null or @group_id ='')
	BEGIN
		SET @group_id = NULL;
	END
	ELSE IF(@group_id = 1)
	BEGIN
		SET @imob_group_id1 =9;
		SET @imob_group_id2 =7;
		SET @imob_group_id3 =8;
		SET @imob_group_id4 =11;
		SET @imob_group_id5 =12;
		SET @imob_group_id6 =15;
	END
	-----------------------CustomerID is not null --------------------------
If (@customer_id is not null and @customer_id !='')
Begin
   ------------------------IP Address is not null --------------------------
	IF(@ip_address is not null and @ip_address !='')
	BEGIN
	print('CustomerID && IP address ')
	;WITH customer_temp AS
				(
                    SELECT customer.customer_id,customer.WID,customer.first_name,customer.last_name,ip_address,ip_scanned,
                    ROW_NUMBER() OVER(ORDER BY customer_id DESC) as intRow, 
                    COUNT(customer.customer_id) OVER() AS total_count ,    
			        customer.email ,customer.status, cusGroup.group_name as [group] 
					from customer 
					join customer_group as cusGroup
					on customer.group_id = cusGroup.group_id
				   and (@group_id is null or cusGroup.group_id = @group_id
					or cusGroup.group_id = @imob_group_id1 or cusGroup.group_id = @imob_group_id2 
					or cusGroup.group_id = @imob_group_id3 or cusGroup.group_id = @imob_group_id4
					or cusGroup.group_id = @imob_group_id5 or cusGroup.group_id = @imob_group_id6)
					where customer.customer_id= @customer_id 
					AND (@wid is null or customer.WID like '%'+ @wid+'%')
					AND (customer.ip_address like '%'+ @ip_address+'%')
					AND (@ip_scanned is null or customer.ip_scanned like '%'+ @ip_scanned+'%')
					AND (@customer_name is null  or Lower(customer.first_name +' '+ customer.last_name) LIKE Lower( '%'+@customer_name +'%'))
					AND (@customer_email is null  or Lower(customer.email) LIKE Lower('%'+LTRIM(RTRIM(@customer_email))+'%'))   
					
					),
					alltime_total_expired_evoucher_temp as
					(select customer_id, COUNT(*)  AS alltime_total_expired_evoucher 
					from customer_earned_evouchers  
					where  customer_id = @customer_id and       
					CAST(customer_earned_evouchers.created_at AS DATE) <= @CURRENT_DATETIME 
					AND CAST (customer_earned_evouchers.expired_date AS  Date) <= CAST (@CURRENT_DATETIME AS Date)   
					and used_status =0
					group by customer_id)
					

				select c.customer_id, c.WID, first_name,last_name,email,[status],[group],total_count,ip_address,c.ip_scanned,
				cb.total_scans as Total_Scan,cb.total_points as Total_Points,cb.total_winks as Total_WINKs,cb.total_evouchers as Total_Evouchers,
				cb.total_redeemed_amt as Total_Redeemed_Amount,
				(IsNull(cb.total_points,0) -( IsNull(cb.used_points,0)+IsNull(cb.confiscated_points,0))) as balanced_points,
				(ISNULL (cb.total_winks,0)- ISNULL (cb.used_winks ,0 )-ISNULL(cb.confiscated_winks,0)) as balanced_winks,
				(ISNULL (cb.total_evouchers,0)-  ISNULL (cb.total_used_evouchers,0) - ISNULl (alltime_total_expired_evoucher,0)) as balanced_evouchers,
				cb.used_points as Used_points, cb.used_winks as Used_Winks,cb.total_used_evouchers as total_Used_eVouchers,
				cb.confiscated_points as Confiscated_points,cb.confiscated_winks as Confiscated_Winks,alltime_total_expired_evoucher as Expired_eVouchers
								
				From customer_temp as c left join
				customer_balance as cb 
				on c.customer_id = cb.customer_id
				 left join alltime_total_expired_evoucher_temp as i
				 on i.customer_id =c.customer_id
				 group by c.customer_id, c.WID,first_name,last_name,email, [status], [group],ip_address,c.ip_scanned,alltime_total_expired_evoucher,
				 total_scans,total_count,
				total_points, total_winks,total_evouchers,total_redeemed_amt,used_points,used_winks,total_used_evouchers,confiscated_points,confiscated_winks
				order by Total_Scan desc;
	END			
	----------------------IP Scanned is not null ---------------------------
	ELSE IF (@ip_scanned is not null and @ip_scanned !='')	
	BEGIN
	print('CustomerID && IP scanned ')
	;WITH customer_temp AS
				(
                    SELECT customer.customer_id,customer.WID,customer.first_name,customer.last_name,ip_address,ip_scanned,
                    ROW_NUMBER() OVER(ORDER BY customer_id DESC) as intRow, 
                    COUNT(customer.customer_id) OVER() AS total_count ,    
			        customer.email ,customer.status, cusGroup.group_name as [group] 
					from customer 
					join customer_group as cusGroup
					on customer.group_id = cusGroup.group_id
				   and (@group_id is null or cusGroup.group_id = @group_id
					or cusGroup.group_id = @imob_group_id1 or cusGroup.group_id = @imob_group_id2 
					or cusGroup.group_id = @imob_group_id3 or cusGroup.group_id = @imob_group_id4
					or cusGroup.group_id = @imob_group_id5 or cusGroup.group_id = @imob_group_id6)
					where customer.customer_id= @customer_id 
					AND (customer.ip_scanned like '%'+ @ip_scanned+'%')
					AND (@wid is null or customer.WID like '%'+ @wid+'%')
					AND (@customer_name is null  or Lower(customer.first_name +' '+ customer.last_name) LIKE Lower( '%'+@customer_name +'%'))
					AND (@customer_email is null  or Lower(customer.email) LIKE Lower('%'+LTRIM(RTRIM(@customer_email))+'%')) 
					
					),
					alltime_total_expired_evoucher_temp as
					(select customer_id, COUNT(*)  AS alltime_total_expired_evoucher 
					from customer_earned_evouchers  
					where  customer_id = @customer_id and       
					CAST(customer_earned_evouchers.created_at AS DATE) <= @CURRENT_DATETIME 
					AND CAST (customer_earned_evouchers.expired_date AS  Date) <= CAST (@CURRENT_DATETIME AS Date)   
					and used_status =0
					group by customer_id)
					

				select c.customer_id, c.WID, first_name,last_name,email,[status],[group],total_count,ip_address,c.ip_scanned,
				cb.total_scans as Total_Scan,cb.total_points as Total_Points,cb.total_winks as Total_WINKs,cb.total_evouchers as Total_Evouchers,
				cb.total_redeemed_amt as Total_Redeemed_Amount,
				(IsNull(cb.total_points,0) -( IsNull(cb.used_points,0)+IsNull(cb.confiscated_points,0))) as balanced_points,
				(ISNULL (cb.total_winks,0)- ISNULL (cb.used_winks ,0 )-ISNULL(cb.confiscated_winks,0)) as balanced_winks,
				(ISNULL (cb.total_evouchers,0)-  ISNULL (cb.total_used_evouchers,0) - ISNULl (alltime_total_expired_evoucher,0)) as balanced_evouchers,
				cb.used_points as Used_points, cb.used_winks as Used_Winks,cb.total_used_evouchers as total_Used_eVouchers,
				cb.confiscated_points as Confiscated_points,cb.confiscated_winks as Confiscated_Winks,alltime_total_expired_evoucher as Expired_eVouchers
								
				From customer_temp as c left join
				customer_balance as cb 
				on c.customer_id = cb.customer_id
				 left join alltime_total_expired_evoucher_temp as i
				 on i.customer_id =c.customer_id
				 group by c.customer_id, c.WID,first_name,last_name,email, [status], [group],ip_address,c.ip_scanned,alltime_total_expired_evoucher,
				 total_scans,total_count,
				total_points, total_winks,total_evouchers,total_redeemed_amt,used_points,used_winks,total_used_evouchers,confiscated_points,confiscated_winks
				order by Total_Scan desc;
	END
	-------------------------No IP Filter ------------------------------------
	ELSE
	BEGIN
	print('CustomerID')
	;WITH customer_temp AS
				(
                    SELECT customer.customer_id,customer.WID,customer.first_name,customer.last_name,ip_address,ip_scanned,
                    ROW_NUMBER() OVER(ORDER BY customer_id DESC) as intRow, 
                    COUNT(customer.customer_id) OVER() AS total_count ,    
			        customer.email ,customer.status, cusGroup.group_name as [group] 
					from customer 
					join customer_group as cusGroup
					on customer.group_id = cusGroup.group_id
				   and (@group_id is null or cusGroup.group_id = @group_id
					or cusGroup.group_id = @imob_group_id1 or cusGroup.group_id = @imob_group_id2 
					or cusGroup.group_id = @imob_group_id3 or cusGroup.group_id = @imob_group_id4
					or cusGroup.group_id = @imob_group_id5 or cusGroup.group_id = @imob_group_id6)
					where customer.customer_id= @customer_id 
					AND (@wid is null or customer.WID like '%'+ @wid+'%')
					AND (@customer_name is null  or Lower(customer.first_name +' '+ customer.last_name) LIKE Lower( '%'+@customer_name +'%'))
					AND (@customer_email is null  or Lower(customer.email) LIKE Lower('%'+LTRIM(RTRIM(@customer_email))+'%')) 
					
					),
					alltime_total_expired_evoucher_temp as
					(select customer_id, COUNT(*)  AS alltime_total_expired_evoucher 
					from customer_earned_evouchers  
					where  customer_id = @customer_id and       
					CAST(customer_earned_evouchers.created_at AS DATE) <= @CURRENT_DATETIME 
					AND CAST (customer_earned_evouchers.expired_date AS  Date) <= CAST (@CURRENT_DATETIME AS Date)   
					and used_status =0
					group by customer_id)
					

				select c.customer_id, c.WID, first_name,last_name,email,[status],[group],total_count,ip_address,c.ip_scanned,
				cb.total_scans as Total_Scan,cb.total_points as Total_Points,cb.total_winks as Total_WINKs,cb.total_evouchers as Total_Evouchers,
				cb.total_redeemed_amt as Total_Redeemed_Amount,
				(IsNull(cb.total_points,0) -( IsNull(cb.used_points,0)+IsNull(cb.confiscated_points,0))) as balanced_points,
				(ISNULL (cb.total_winks,0)- ISNULL (cb.used_winks ,0 )-ISNULL(cb.confiscated_winks,0)) as balanced_winks,
				(ISNULL (cb.total_evouchers,0)-  ISNULL (cb.total_used_evouchers,0) - ISNULl (alltime_total_expired_evoucher,0)) as balanced_evouchers,
				cb.used_points as Used_points, cb.used_winks as Used_Winks,cb.total_used_evouchers as total_Used_eVouchers,
				cb.confiscated_points as Confiscated_points,cb.confiscated_winks as Confiscated_Winks,alltime_total_expired_evoucher as Expired_eVouchers
								
				From customer_temp as c left join
				customer_balance as cb 
				on c.customer_id = cb.customer_id
				 left join alltime_total_expired_evoucher_temp as i
				 on i.customer_id =c.customer_id
				 group by c.customer_id, c.WID,first_name,last_name,email, [status], [group],ip_address,c.ip_scanned,alltime_total_expired_evoucher,
				 total_scans,total_count,
				total_points, total_winks,total_evouchers,total_redeemed_amt,used_points,used_winks,total_used_evouchers,confiscated_points,confiscated_winks
				order by Total_Scan desc;
	END
End
	----------------------Customer ID is null ---------------------------------
Else
Begin
	 ------------------------IP Address is not null --------------------------
	IF(@ip_address is not null and @ip_address !='')
	BEGIN
	print('IP address ')
	;WITH customer_temp AS
				(
                    SELECT customer.customer_id,customer.WID,customer.first_name,customer.last_name,ip_address,ip_scanned,
                    ROW_NUMBER() OVER(ORDER BY customer_id DESC) as intRow, 
                    COUNT(customer.customer_id) OVER() AS total_count ,    
			        customer.email ,customer.status, cusGroup.group_name as [group] 
					from customer 
					join customer_group as cusGroup
					on customer.group_id = cusGroup.group_id
				   and (@group_id is null or cusGroup.group_id = @group_id
					or cusGroup.group_id = @imob_group_id1 or cusGroup.group_id = @imob_group_id2 
					or cusGroup.group_id = @imob_group_id3 or cusGroup.group_id = @imob_group_id4
					or cusGroup.group_id = @imob_group_id5 or cusGroup.group_id = @imob_group_id6)
					where customer.ip_address like '%'+ @ip_address+'%'
					AND (@wid is null or customer.WID like '%'+ @wid+'%')
					AND (@ip_scanned is null or customer.ip_scanned like '%'+ @ip_scanned+'%')
					AND (@customer_name is null  or Lower(customer.first_name +' '+ customer.last_name) LIKE Lower( '%'+@customer_name +'%'))
					AND (@customer_email is null  or Lower(customer.email) LIKE Lower('%'+LTRIM(RTRIM(@customer_email))+'%'))  
					
					),
					alltime_total_expired_evoucher_temp as
					(select customer_id, COUNT(*)  AS alltime_total_expired_evoucher 
					from customer_earned_evouchers  
					where  customer_id = @customer_id and       
					CAST(customer_earned_evouchers.created_at AS DATE) <= @CURRENT_DATETIME 
					AND CAST (customer_earned_evouchers.expired_date AS  Date) <= CAST (@CURRENT_DATETIME AS Date)   
					and used_status =0
					group by customer_id)
					

				select c.customer_id, c.WID, first_name,last_name,email,[status],[group],total_count,ip_address,c.ip_scanned,
				cb.total_scans as Total_Scan,cb.total_points as Total_Points,cb.total_winks as Total_WINKs,cb.total_evouchers as Total_Evouchers,
				cb.total_redeemed_amt as Total_Redeemed_Amount,
				(IsNull(cb.total_points,0) -( IsNull(cb.used_points,0)+IsNull(cb.confiscated_points,0))) as balanced_points,
				(ISNULL (cb.total_winks,0)- ISNULL (cb.used_winks ,0 )-ISNULL(cb.confiscated_winks,0)) as balanced_winks,
				(ISNULL (cb.total_evouchers,0)-  ISNULL (cb.total_used_evouchers,0) - ISNULl (alltime_total_expired_evoucher,0)) as balanced_evouchers,
				cb.used_points as Used_points, cb.used_winks as Used_Winks,cb.total_used_evouchers as total_Used_eVouchers,
				cb.confiscated_points as Confiscated_points,cb.confiscated_winks as Confiscated_Winks,alltime_total_expired_evoucher as Expired_eVouchers
								
				From customer_temp as c left join
				customer_balance as cb 
				on c.customer_id = cb.customer_id
				 left join alltime_total_expired_evoucher_temp as i
				 on i.customer_id =c.customer_id
				 group by c.customer_id, c.WID,first_name,last_name,email, [status], [group],ip_address,c.ip_scanned,alltime_total_expired_evoucher,
				 total_scans,total_count,
				total_points, total_winks,total_evouchers,total_redeemed_amt,used_points,used_winks,total_used_evouchers,confiscated_points,confiscated_winks
				order by Total_Scan desc;
	END	
	----------------------IP Scanned is not null ---------------------------
	ELSE IF (@ip_scanned is not null and @ip_scanned !='')	
	BEGIN
	print(' IP scanned ')
	;WITH customer_temp AS
				(
                    SELECT customer.customer_id,customer.WID,customer.first_name,customer.last_name,ip_address,ip_scanned,
                    ROW_NUMBER() OVER(ORDER BY customer_id DESC) as intRow, 
                    COUNT(customer.customer_id) OVER() AS total_count ,    
			        customer.email ,customer.status, cusGroup.group_name as [group] 
					from customer 
					join customer_group as cusGroup
					on customer.group_id = cusGroup.group_id
				   and (@group_id is null or cusGroup.group_id = @group_id
					or cusGroup.group_id = @imob_group_id1 or cusGroup.group_id = @imob_group_id2 
					or cusGroup.group_id = @imob_group_id3 or cusGroup.group_id = @imob_group_id4
					or cusGroup.group_id = @imob_group_id5 or cusGroup.group_id = @imob_group_id6)
					where customer.ip_scanned like '%'+ @ip_scanned+'%'
					AND (@wid is null or customer.WID like '%'+ @wid+'%')
					AND (@customer_name is null  or Lower(customer.first_name +' '+ customer.last_name) LIKE Lower( '%'+@customer_name +'%'))
					AND (@customer_email is null  or Lower(customer.email) LIKE Lower('%'+LTRIM(RTRIM(@customer_email))+'%')) 
					
					),
					alltime_total_expired_evoucher_temp as
					(select customer_id, COUNT(*)  AS alltime_total_expired_evoucher 
					from customer_earned_evouchers  
					where  customer_id = @customer_id and       
					CAST(customer_earned_evouchers.created_at AS DATE) <= @CURRENT_DATETIME 
					AND CAST (customer_earned_evouchers.expired_date AS  Date) <= CAST (@CURRENT_DATETIME AS Date)   
					and used_status =0
					group by customer_id)
					

				select c.customer_id, c.WID, first_name,last_name,email,[status],[group],total_count,ip_address,c.ip_scanned,
				cb.total_scans as Total_Scan,cb.total_points as Total_Points,cb.total_winks as Total_WINKs,cb.total_evouchers as Total_Evouchers,
				cb.total_redeemed_amt as Total_Redeemed_Amount,
				(IsNull(cb.total_points,0) -( IsNull(cb.used_points,0)+IsNull(cb.confiscated_points,0))) as balanced_points,
				(ISNULL (cb.total_winks,0)- ISNULL (cb.used_winks ,0 )-ISNULL(cb.confiscated_winks,0)) as balanced_winks,
				(ISNULL (cb.total_evouchers,0)-  ISNULL (cb.total_used_evouchers,0) - ISNULl (alltime_total_expired_evoucher,0)) as balanced_evouchers,
				cb.used_points as Used_points, cb.used_winks as Used_Winks,cb.total_used_evouchers as total_Used_eVouchers,
				cb.confiscated_points as Confiscated_points,cb.confiscated_winks as Confiscated_Winks,alltime_total_expired_evoucher as Expired_eVouchers
								
				From customer_temp as c left join
				customer_balance as cb 
				on c.customer_id = cb.customer_id
				 left join alltime_total_expired_evoucher_temp as i
				 on i.customer_id =c.customer_id
				 group by c.customer_id, c.WID,first_name,last_name,email, [status], [group],ip_address,c.ip_scanned,alltime_total_expired_evoucher,
				 total_scans,total_count,
				total_points, total_winks,total_evouchers,total_redeemed_amt,used_points,used_winks,total_used_evouchers,confiscated_points,confiscated_winks
				order by Total_Scan desc;
	END
	-------------------------No IP Filter ------------------------------------
	ELSE
	BEGIN
	print('wid,name, email ')
	;WITH customer_temp AS
				(
                    SELECT customer.customer_id,customer.WID,customer.first_name,customer.last_name,ip_address,ip_scanned,
                    ROW_NUMBER() OVER(ORDER BY customer_id DESC) as intRow, 
                    COUNT(customer.customer_id) OVER() AS total_count ,    
			        customer.email ,customer.status, cusGroup.group_name as [group] 
					from customer 
					join customer_group as cusGroup
					on customer.group_id = cusGroup.group_id
				   and (@group_id is null or cusGroup.group_id = @group_id
					or cusGroup.group_id = @imob_group_id1 or cusGroup.group_id = @imob_group_id2 
					or cusGroup.group_id = @imob_group_id3 or cusGroup.group_id = @imob_group_id4
					or cusGroup.group_id = @imob_group_id5 or cusGroup.group_id = @imob_group_id6)
					Where (@customer_name is null or (Lower(customer.first_name +' '+ customer.last_name) LIKE Lower('%'+@customer_name +'%')))     
					AND (@wid is null or customer.WID like '%'+ @wid+'%')
					AND (@customer_email is null or (Lower(customer.email) LIKE Lower('%'+LTRIM(RTRIM(@customer_email))+'%')))
					
					),
					alltime_total_expired_evoucher_temp as
					(select customer_id, COUNT(*)  AS alltime_total_expired_evoucher 
					from customer_earned_evouchers  
					where  customer_id = @customer_id and       
					CAST(customer_earned_evouchers.created_at AS DATE) <= @CURRENT_DATETIME 
					AND CAST (customer_earned_evouchers.expired_date AS  Date) <= CAST (@CURRENT_DATETIME AS Date)   
					and used_status =0
					group by customer_id)
					

				select c.customer_id, c.WID, first_name,last_name,email,[status],[group],total_count,ip_address,c.ip_scanned,
				cb.total_scans as Total_Scan,cb.total_points as Total_Points,cb.total_winks as Total_WINKs,cb.total_evouchers as Total_Evouchers,
				cb.total_redeemed_amt as Total_Redeemed_Amount,
				(IsNull(cb.total_points,0) -( IsNull(cb.used_points,0)+IsNull(cb.confiscated_points,0))) as balanced_points,
				(ISNULL (cb.total_winks,0)- ISNULL (cb.used_winks ,0 )-ISNULL(cb.confiscated_winks,0)) as balanced_winks,
				(ISNULL (cb.total_evouchers,0)-  ISNULL (cb.total_used_evouchers,0) - ISNULl (alltime_total_expired_evoucher,0)) as balanced_evouchers,
				cb.used_points as Used_points, cb.used_winks as Used_Winks,cb.total_used_evouchers as total_Used_eVouchers,
				cb.confiscated_points as Confiscated_points,cb.confiscated_winks as Confiscated_Winks,alltime_total_expired_evoucher as Expired_eVouchers
								
				From customer_temp as c left join
				customer_balance as cb 
				on c.customer_id = cb.customer_id
				 left join alltime_total_expired_evoucher_temp as i
				 on i.customer_id =c.customer_id
				 group by c.customer_id, c.WID,first_name,last_name,email, [status], [group],ip_address,c.ip_scanned,alltime_total_expired_evoucher,
				 total_scans,total_count,
				total_points, total_winks,total_evouchers,total_redeemed_amt,used_points,used_winks,total_used_evouchers,confiscated_points,confiscated_winks
				order by Total_Scan desc;
	END
End

End
