CREATE PROCEDURE [dbo].[Get_Customer_Report_With_Paging_WithDateFilter_testing]      
 (@start_date datetime,      
  @end_date datetime,      
  @customer_name varchar(150),      
  @customer_email varchar(150),
  @ip_address varchar(50),
  @status varchar(10),
  @customer_id INT,
  @wid varchar(50),
  @group_id varchar(10),
  @ip_scanned varchar(30),
  @intPage int,
  @intPageSize int
  )      
AS      
BEGIN     
	DECLARE @intStartRow int;
    DECLARE @intEndRow int;
    DECLARE @total int
    SET @intStartRow = (@intPage -1) * @intPageSize + 1;
    SET @intEndRow = @intPage * @intPageSize;
	Declare @CURRENT_DATETIME Datetime      
	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUTPUT   
	DECLARE @auto_status varchar(5)     

	--SET NOCOUNT ON;
	SET @auto_status ='';
	IF(@status='auto')
	BEGIN
		SET @status ='disable';
		SET @auto_status ='1';
	END
	ELSE IF(@status='login')
	BEGIN
		Print('Login');
		SET @status ='disable';
		SET @auto_status ='2';
	END
	if(@customer_id is null or @customer_id='')
	BEGIN
		SET @customer_id =null;
	END
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
	IF(@status is null or @status = '')
	BEGIN
		SET @status = null;
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
	IF (@start_date IS NOT NULL AND @end_date IS NOT NULL AND @start_date!='' AND @end_date !='') 
	BEGIN
		IF(@customer_id IS NOT NULL AND @customer_id != '')    
		BEGIN
			--------------------------------IP Is not null ---------------------------------------
			IF(@ip_address is not null and @ip_address !='')
			BEGIN 
			   	;WITH customer_temp AS
				(
                    SELECT customer.customer_id,customer.WID,customer.first_name,customer.last_name,ip_address,ip_scanned,
                    ROW_NUMBER() OVER(ORDER BY customer_id DESC) as intRow, 
                    COUNT(customer.customer_id) OVER() AS total_count ,    
			        customer.email ,customer.status, cusGroup.group_name as [group] from customer 
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
					AND (@status is null  or Lower(customer.[status]) LIKE Lower(@status+'%') )
					  
					  and ( 
							(customer.customer_id in 
								(
									select customer_id 
									from customer_earned_points 
									where CONVERT(CHAR (10),customer_earned_points.created_at,111)       
									BETWEEN CONVERT(CHAR(10),@start_date,111) and CONVERT(CHAR(10),@end_date,111) 
									Group by customer_id
								)
							)
							OR 
					  
						(customer.customer_id in 
								(select customer_id from wink_net_canid_earned_points 
								where 
							CONVERT(CHAR (10),wink_net_canid_earned_points.created_at,111)   
							BETWEEN CONVERT(CHAR(10),@start_date,111) and 
							CONVERT(CHAR(10),@end_date,111) 
								Group by customer_id)
						)
						OR
						(customer.customer_id in 
							(select customer_id 
							from winktag_customer_earned_points 
							where  CAST(winktag_customer_earned_points.created_at AS DATE)       
							BETWEEN CONVERT(CHAR(10),@start_date,111) and CONVERT(CHAR(10),@end_date,111) 
							Group by customer_id)
						)
						OR
						(customer.customer_id in 
							(select customer_id 
							from winners_points 
							where  CAST(winners_points.created_at AS DATE)       
							BETWEEN CONVERT(CHAR(10),@start_date,111) and CONVERT(CHAR(10),@end_date,111) 
							Group by customer_id)
						)
						OR
						(customer.customer_id in 
							(select c.customer_id         
							from points_issuance as cpi, customer as c
							where cpi.wid like c.WID
							AND points != 0
							AND approver IS NOT NULL
							AND remark_approver IS NULL
							AND (
								CAST(cpi.created_at AS DATE)       
								BETWEEN CAST(@start_date as date) AND Cast(@end_date as date)
							) 
							Group by c.customer_id)
						)
						OR
						(customer.customer_id in 
							(	select customer_id         
								from wink_canid_earned_points
								where 
								(
									CAST(created_at AS DATE)       
									BETWEEN CAST(@start_date as date) AND Cast(@end_date as date)
								) 
								Group by customer_id
							)
						)
						OR
						(customer.customer_id in 
							(	select customer_id         
								from wink_gate_points_earned
								where 
								(
									CAST(created_at AS DATE)       
									BETWEEN CAST(@start_date as date) AND Cast(@end_date as date)
								) 
								Group by customer_id
							)
						)
					)
					
					),
					alltime_total_expired_evoucher_temp as
					(select customer_id, COUNT(*)  AS alltime_total_expired_evoucher 
					from customer_earned_evouchers  
					where  customer_id = @customer_id and       
					CAST(customer_earned_evouchers.created_at AS DATE) <= @end_date 
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
			------------------------------ Ip scanned is not null -----------------------
			ELSE IF (@ip_scanned is not null and @ip_scanned !='')		  
			BEGIN 
			;WITH customer_temp AS
				(
                    SELECT customer.customer_id,customer.WID,customer.first_name,customer.last_name,ip_address,ip_scanned,
                    ROW_NUMBER() OVER(ORDER BY customer_id DESC) as intRow, 
                    COUNT(customer.customer_id) OVER() AS total_count ,    
			        customer.email ,customer.status, cusGroup.group_name as [group] from customer 
					join customer_group as cusGroup
					on customer.group_id = cusGroup.group_id
					and (@group_id is null or cusGroup.group_id = @group_id
					or cusGroup.group_id = @imob_group_id1 or cusGroup.group_id = @imob_group_id2 
					or cusGroup.group_id = @imob_group_id3 or cusGroup.group_id = @imob_group_id4
					or cusGroup.group_id = @imob_group_id5 or cusGroup.group_id = @imob_group_id6)	
					where customer.customer_id= @customer_id 
					AND (customer.ip_scanned like '%'+ @ip_scanned+'%')
					AND (@wid is null or customer.WID like '%'+ @wid+'%')
				--	AND (customer.ip_address is null or customer.ip_address like '%'+ @ip_address+'%')
					AND (@customer_name is null  or Lower(customer.first_name +' '+ customer.last_name) LIKE Lower( '%'+@customer_name +'%'))
					AND (@customer_email is null  or Lower(customer.email) LIKE Lower('%'+LTRIM(RTRIM(@customer_email))+'%'))   
					AND (@status is null  or Lower(customer.[status]) LIKE Lower(@status+'%') )
					  
					  and ( 
							(customer.customer_id in 
								(
									select customer_id 
									from customer_earned_points 
									where CONVERT(CHAR (10),customer_earned_points.created_at,111)       
									BETWEEN CONVERT(CHAR(10),@start_date,111) and CONVERT(CHAR(10),@end_date,111) 
									Group by customer_id
								)
							)
							OR 
					  
						(customer.customer_id in 
								(select customer_id from wink_net_canid_earned_points 
								where 
							CONVERT(CHAR (10),wink_net_canid_earned_points.created_at,111)   
							BETWEEN CONVERT(CHAR(10),@start_date,111) and 
							CONVERT(CHAR(10),@end_date,111) 
								Group by customer_id)
						)
						OR
						(customer.customer_id in 
							(select customer_id 
							from winktag_customer_earned_points 
							where  CAST(winktag_customer_earned_points.created_at AS DATE)       
							BETWEEN CONVERT(CHAR(10),@start_date,111) and CONVERT(CHAR(10),@end_date,111) 
							Group by customer_id)
						)
						OR
						(customer.customer_id in 
							(select customer_id 
							from winners_points 
							where  CAST(winners_points.created_at AS DATE)       
							BETWEEN CONVERT(CHAR(10),@start_date,111) and CONVERT(CHAR(10),@end_date,111) 
							Group by customer_id)
						)
						OR
						(customer.customer_id in 
							(select c.customer_id         
							from points_issuance as cpi, customer as c
							where cpi.wid like c.WID
							AND points != 0
							AND approver IS NOT NULL
							AND remark_approver IS NULL
							AND (
								CAST(cpi.created_at AS DATE)       
								BETWEEN CAST(@start_date as date) AND Cast(@end_date as date)
							) 
							Group by c.customer_id)
						)
						OR
						(customer.customer_id in 
							(	select customer_id         
								from wink_canid_earned_points
								where 
								(
									CAST(created_at AS DATE)       
									BETWEEN CAST(@start_date as date) AND Cast(@end_date as date)
								) 
								Group by customer_id
							)
						)
						OR
						(customer.customer_id in 
							(	select customer_id         
								from wink_gate_points_earned
								where 
								(
									CAST(created_at AS DATE)       
									BETWEEN CAST(@start_date as date) AND Cast(@end_date as date)
								) 
								Group by customer_id
							)
						)
					)
					
					),
					alltime_total_expired_evoucher_temp as
					(select customer_id, COUNT(*)  AS alltime_total_expired_evoucher 
					from customer_earned_evouchers  
					where  customer_id = @customer_id and       
					CAST(customer_earned_evouchers.created_at AS DATE) <= @end_date 
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
			---------------------------NO IP Filter -------------------------------------------- 
			ELSE   
			BEGIN
			 	;WITH customer_temp AS
				(
                    SELECT customer.customer_id,customer.WID,customer.first_name,customer.last_name,ip_address,ip_scanned,
                    ROW_NUMBER() OVER(ORDER BY customer_id DESC) as intRow, 
                    COUNT(customer.customer_id) OVER() AS total_count ,    
			        customer.email ,customer.status, cusGroup.group_name as [group] from customer 
					join customer_group as cusGroup
					on customer.group_id = cusGroup.group_id
					and (@group_id is null or cusGroup.group_id = @group_id
					or cusGroup.group_id = @imob_group_id1 or cusGroup.group_id = @imob_group_id2 
					or cusGroup.group_id = @imob_group_id3 or cusGroup.group_id = @imob_group_id4
					or cusGroup.group_id = @imob_group_id5 or cusGroup.group_id = @imob_group_id6)	
					where customer.customer_id= @customer_id 
					AND (@wid is null or customer.WID like '%'+ @wid+'%')
					--AND (customer.ip_address like '%'+ @ip_address+'%')
					--AND (@ip_scanned is null or customer.ip_scanned like '%'+ @ip_scanned+'%')
					AND (@customer_name is null  or Lower(customer.first_name +' '+ customer.last_name) LIKE Lower( '%'+@customer_name +'%'))
					AND (@customer_email is null  or Lower(customer.email) LIKE Lower('%'+LTRIM(RTRIM(@customer_email))+'%'))   
					AND (@status is null  or Lower(customer.[status]) LIKE Lower(@status+'%') )
					  
					  and ( 
							(customer.customer_id in 
								(
									select customer_id 
									from customer_earned_points 
									where CONVERT(CHAR (10),customer_earned_points.created_at,111)       
									BETWEEN CONVERT(CHAR(10),@start_date,111) and CONVERT(CHAR(10),@end_date,111) 
									Group by customer_id
								)
							)
							OR 
					  
						(customer.customer_id in 
								(select customer_id from wink_net_canid_earned_points 
								where 
							CONVERT(CHAR (10),wink_net_canid_earned_points.created_at,111)   
							BETWEEN CONVERT(CHAR(10),@start_date,111) and 
							CONVERT(CHAR(10),@end_date,111) 
								Group by customer_id)
						)
						OR
						(customer.customer_id in 
							(select customer_id 
							from winktag_customer_earned_points 
							where  CAST(winktag_customer_earned_points.created_at AS DATE)       
							BETWEEN CONVERT(CHAR(10),@start_date,111) and CONVERT(CHAR(10),@end_date,111) 
							Group by customer_id)
						)
						OR
						(customer.customer_id in 
							(select customer_id 
							from winners_points 
							where  CAST(winners_points.created_at AS DATE)       
							BETWEEN CONVERT(CHAR(10),@start_date,111) and CONVERT(CHAR(10),@end_date,111) 
							Group by customer_id)
						)
						OR
						(customer.customer_id in 
							(select c.customer_id         
							from points_issuance as cpi, customer as c
							where cpi.wid like c.WID
							AND points != 0
							AND approver IS NOT NULL
							AND remark_approver IS NULL
							AND (
								CAST(cpi.created_at AS DATE)       
								BETWEEN CAST(@start_date as date) AND Cast(@end_date as date)
							) 
							Group by c.customer_id)
						)
						OR
						(customer.customer_id in 
							(	select customer_id         
								from wink_canid_earned_points
								where 
								(
									CAST(created_at AS DATE)       
									BETWEEN CAST(@start_date as date) AND Cast(@end_date as date)
								) 
								Group by customer_id
							)
						)
						OR
						(customer.customer_id in 
							(	select customer_id         
								from wink_gate_points_earned
								where 
								(
									CAST(created_at AS DATE)       
									BETWEEN CAST(@start_date as date) AND Cast(@end_date as date)
								) 
								Group by customer_id
							)
						)
					)
					
					),
					alltime_total_expired_evoucher_temp as
					(select customer_id, COUNT(*)  AS alltime_total_expired_evoucher 
					from customer_earned_evouchers  
					where  customer_id = @customer_id and       
					CAST(customer_earned_evouchers.created_at AS DATE) <= @end_date 
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
		END
	----------------------------End Filter Customer ID
		ELSE
		BEGIN
			---------------------IP Address is not NUll
			IF (@ip_address is not null and @ip_address !='')
			BEGIN
			print('customer id is null, ip address is not null')

				;WITH customer_temp AS
				(
                    SELECT customer.customer_id,customer.WID,customer.first_name,customer.last_name,ip_address,ip_scanned,
                    ROW_NUMBER() OVER(ORDER BY customer_id DESC) as intRow, 
                    COUNT(customer.customer_id) OVER() AS total_count ,    
			        customer.email ,customer.status, cusGroup.group_name as [group] from customer 
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
					AND (@status is null  or Lower(customer.[status]) LIKE Lower(@status+'%') )
					  
					  and ( 
							(customer.customer_id in 
								(
									select customer_id 
									from customer_earned_points 
									where CONVERT(CHAR (10),customer_earned_points.created_at,111)       
									BETWEEN CONVERT(CHAR(10),@start_date,111) and CONVERT(CHAR(10),@end_date,111) 
									Group by customer_id
								)
							)
							OR 
					  
						(customer.customer_id in 
								(select customer_id from wink_net_canid_earned_points 
								where 
							CONVERT(CHAR (10),wink_net_canid_earned_points.created_at,111)   
							BETWEEN CONVERT(CHAR(10),@start_date,111) and 
							CONVERT(CHAR(10),@end_date,111) 
								Group by customer_id)
						)
						OR
						(customer.customer_id in 
							(select customer_id 
							from winktag_customer_earned_points 
							where  CAST(winktag_customer_earned_points.created_at AS DATE)       
							BETWEEN CONVERT(CHAR(10),@start_date,111) and CONVERT(CHAR(10),@end_date,111) 
							Group by customer_id)
						)
						OR
						(customer.customer_id in 
							(select customer_id 
							from winners_points 
							where  CAST(winners_points.created_at AS DATE)       
							BETWEEN CONVERT(CHAR(10),@start_date,111) and CONVERT(CHAR(10),@end_date,111) 
							Group by customer_id)
						)
						OR
						(customer.customer_id in 
							(select c.customer_id         
							from points_issuance as cpi, customer as c
							where cpi.wid like c.WID
							AND points != 0
							AND approver IS NOT NULL
							AND remark_approver IS NULL
							AND (
								CAST(cpi.created_at AS DATE)       
								BETWEEN CAST(@start_date as date) AND Cast(@end_date as date)
							) 
							Group by c.customer_id)
						)
						OR
						(customer.customer_id in 
							(	select customer_id         
								from wink_canid_earned_points
								where 
								(
									CAST(created_at AS DATE)       
									BETWEEN CAST(@start_date as date) AND Cast(@end_date as date)
								) 
								Group by customer_id
							)
						)
						OR
						(customer.customer_id in 
							(	select customer_id         
								from wink_gate_points_earned
								where 
								(
									CAST(created_at AS DATE)       
									BETWEEN CAST(@start_date as date) AND Cast(@end_date as date)
								) 
								Group by customer_id
							)
						)
					)
					
					),
					alltime_total_expired_evoucher_temp as
					(select customer_id, COUNT(*)  AS alltime_total_expired_evoucher 
					from customer_earned_evouchers  
					where  customer_id = @customer_id and       
					CAST(customer_earned_evouchers.created_at AS DATE) <= @end_date 
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
			------------------------------ Ip scanned is not null -----------------------
			ELSE IF (@ip_scanned is not null and @ip_scanned !='')		  
			BEGIN 
				print('customer id is null, ip scanned is not null')
			;WITH customer_temp AS
				(
                    SELECT customer.customer_id,customer.WID,customer.first_name,customer.last_name,ip_address,ip_scanned,
                    ROW_NUMBER() OVER(ORDER BY customer_id DESC) as intRow, 
                    COUNT(customer.customer_id) OVER() AS total_count ,    
			        customer.email ,customer.status, cusGroup.group_name as [group] from customer 
					join customer_group as cusGroup
					on customer.group_id = cusGroup.group_id
					and (@group_id is null or cusGroup.group_id = @group_id
					or cusGroup.group_id = @imob_group_id1 or cusGroup.group_id = @imob_group_id2 
					or cusGroup.group_id = @imob_group_id3 or cusGroup.group_id = @imob_group_id4
					or cusGroup.group_id = @imob_group_id5 or cusGroup.group_id = @imob_group_id6)	
					where customer.ip_scanned like '%'+ @ip_scanned+'%'
					AND (@wid is null or customer.WID like '%'+ @wid+'%')
					--AND (customer.ip_address is null or customer.ip_address like '%'+ @ip_address+'%')
					AND (@customer_name is null  or Lower(customer.first_name +' '+ customer.last_name) LIKE Lower( '%'+@customer_name +'%'))
					AND (@customer_email is null  or Lower(customer.email) LIKE Lower('%'+LTRIM(RTRIM(@customer_email))+'%'))   
					AND (@status is null  or Lower(customer.[status]) LIKE Lower(@status+'%') )
					  
					  and ( 
							(customer.customer_id in 
								(
									select customer_id 
									from customer_earned_points 
									where CONVERT(CHAR (10),customer_earned_points.created_at,111)       
									BETWEEN CONVERT(CHAR(10),@start_date,111) and CONVERT(CHAR(10),@end_date,111) 
									Group by customer_id
								)
							)
							OR 
					  
						(customer.customer_id in 
								(select customer_id from wink_net_canid_earned_points 
								where 
							CONVERT(CHAR (10),wink_net_canid_earned_points.created_at,111)   
							BETWEEN CONVERT(CHAR(10),@start_date,111) and 
							CONVERT(CHAR(10),@end_date,111) 
								Group by customer_id)
						)
						OR
						(customer.customer_id in 
							(select customer_id 
							from winktag_customer_earned_points 
							where  CAST(winktag_customer_earned_points.created_at AS DATE)       
							BETWEEN CONVERT(CHAR(10),@start_date,111) and CONVERT(CHAR(10),@end_date,111) 
							Group by customer_id)
						)
						OR
						(customer.customer_id in 
							(select customer_id 
							from winners_points 
							where  CAST(winners_points.created_at AS DATE)       
							BETWEEN CONVERT(CHAR(10),@start_date,111) and CONVERT(CHAR(10),@end_date,111) 
							Group by customer_id)
						)
						OR
						(customer.customer_id in 
							(select c.customer_id         
							from points_issuance as cpi, customer as c
							where cpi.wid like c.WID
							AND points != 0
							AND approver IS NOT NULL
							AND remark_approver IS NULL
							AND (
								CAST(cpi.created_at AS DATE)       
								BETWEEN CAST(@start_date as date) AND Cast(@end_date as date)
							) 
							Group by c.customer_id)
						)
						OR
						(customer.customer_id in 
							(	select customer_id         
								from wink_canid_earned_points
								where 
								(
									CAST(created_at AS DATE)       
									BETWEEN CAST(@start_date as date) AND Cast(@end_date as date)
								) 
								Group by customer_id
							)
						)
						OR
						(customer.customer_id in 
							(	select customer_id         
								from wink_gate_points_earned
								where 
								(
									CAST(created_at AS DATE)       
									BETWEEN CAST(@start_date as date) AND Cast(@end_date as date)
								) 
								Group by customer_id
							)
						)
					)
					
					),
					alltime_total_expired_evoucher_temp as
					(select customer_id, COUNT(*)  AS alltime_total_expired_evoucher 
					from customer_earned_evouchers  
					where  customer_id = @customer_id and       
					CAST(customer_earned_evouchers.created_at AS DATE) <= @end_date 
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
			--------------------------Not filter ip adddresss ------------------------------
			ELSE 
			BEGIN
			;WITH customer_temp AS
				(
                    SELECT customer.customer_id,customer.WID,customer.first_name,customer.last_name,ip_address,ip_scanned,
                    ROW_NUMBER() OVER(ORDER BY customer_id DESC) as intRow, 
                    COUNT(customer.customer_id) OVER() AS total_count ,    
			        customer.email ,customer.status, cusGroup.group_name as [group] from customer 
					join customer_group as cusGroup
					on customer.group_id = cusGroup.group_id
					and (@group_id is null or cusGroup.group_id = @group_id
					or cusGroup.group_id = @imob_group_id1 or cusGroup.group_id = @imob_group_id2 
					or cusGroup.group_id = @imob_group_id3 or cusGroup.group_id = @imob_group_id4
					or cusGroup.group_id = @imob_group_id5 or cusGroup.group_id = @imob_group_id6)	
					where (@wid is null or customer.WID like '%'+ @wid+'%')
					AND (@customer_name is null  or Lower(customer.first_name +' '+ customer.last_name) LIKE Lower( '%'+@customer_name +'%'))
					AND (@customer_email is null  or Lower(customer.email) LIKE Lower('%'+LTRIM(RTRIM(@customer_email))+'%'))   
					AND (@status is null  or Lower(customer.[status]) LIKE Lower(@status+'%') )
					  
					  and ( 
							(customer.customer_id in 
								(
									select customer_id 
									from customer_earned_points 
									where CONVERT(CHAR (10),customer_earned_points.created_at,111)       
									BETWEEN CONVERT(CHAR(10),@start_date,111) and CONVERT(CHAR(10),@end_date,111) 
									Group by customer_id
								)
							)
							OR 
					  
						(customer.customer_id in 
								(select customer_id from wink_net_canid_earned_points 
								where 
							CONVERT(CHAR (10),wink_net_canid_earned_points.created_at,111)   
							BETWEEN CONVERT(CHAR(10),@start_date,111) and 
							CONVERT(CHAR(10),@end_date,111) 
								Group by customer_id)
						)
						OR
						(customer.customer_id in 
							(select customer_id 
							from winktag_customer_earned_points 
							where  CAST(winktag_customer_earned_points.created_at AS DATE)       
							BETWEEN CONVERT(CHAR(10),@start_date,111) and CONVERT(CHAR(10),@end_date,111) 
							Group by customer_id)
						)
						OR
						(customer.customer_id in 
							(select customer_id 
							from winners_points 
							where  CAST(winners_points.created_at AS DATE)       
							BETWEEN CONVERT(CHAR(10),@start_date,111) and CONVERT(CHAR(10),@end_date,111) 
							Group by customer_id)
						)
						OR
						(customer.customer_id in 
							(select c.customer_id         
							from points_issuance as cpi, customer as c
							where cpi.wid like c.WID
							AND points != 0
							AND approver IS NOT NULL
							AND remark_approver IS NULL
							AND (
								CAST(cpi.created_at AS DATE)       
								BETWEEN CAST(@start_date as date) AND Cast(@end_date as date)
							) 
							Group by c.customer_id)
						)
						OR
						(customer.customer_id in 
							(	select customer_id         
								from wink_canid_earned_points
								where 
								(
									CAST(created_at AS DATE)       
									BETWEEN CAST(@start_date as date) AND Cast(@end_date as date)
								) 
								Group by customer_id
							)
						)
						OR
						(customer.customer_id in 
							(	select customer_id         
								from wink_gate_points_earned
								where 
								(
									CAST(created_at AS DATE)       
									BETWEEN CAST(@start_date as date) AND Cast(@end_date as date)
								) 
								Group by customer_id
							)
						)
					)
					
					),
					alltime_total_expired_evoucher_temp as
					(select customer_id, COUNT(*)  AS alltime_total_expired_evoucher 
					from customer_earned_evouchers  
					where  customer_id = @customer_id and       
					CAST(customer_earned_evouchers.created_at AS DATE) <= @end_date 
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
				 where intRow between @intStartRow and @intEndRow
				 group by c.customer_id, c.WID,first_name,last_name,email, [status], [group],ip_address,c.ip_scanned,alltime_total_expired_evoucher,
				 total_scans,total_count,
				total_points, total_winks,total_evouchers,total_redeemed_amt,used_points,used_winks,total_used_evouchers,confiscated_points,confiscated_winks
				
				order by Total_Scan desc;
			END
		END
	END

END

