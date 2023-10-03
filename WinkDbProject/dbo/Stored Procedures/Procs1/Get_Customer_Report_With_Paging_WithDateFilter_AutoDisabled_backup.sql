
CREATE PROCEDURE [dbo].[Get_Customer_Report_With_Paging_WithDateFilter_AutoDisabled_backup]      
 (@start_date datetime,      
  @end_date datetime,      
  @customer_name varchar(150),      
  @customer_email varchar(150),
  @ip_address varchar(50),
  @status varchar(50),
  @customer_id INT,
  @ip_scanned varchar(30),
  @wid varchar(50),
  @group_id varchar(10),
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
    
     
	Declare @CURRENT_DATETIME Datetime      
	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUTPUT   
	DECLARE @auto_status varchar(5)     

	--SET NOCOUNT ON;
	CREATE TABLE #Customer_AutoLog_Table      
	(      
		customer_id int,
		locked_desc varchar(50)
	) 
 
	--pp add
	IF OBJECT_ID(N'tempdb..#temp') IS NOT NULL
	BEGIN
		DROP TABLE #temp
	END
	CREATE TABLE #temp      
	(      
		customer_id int,
		created_at date
	) 
 
	insert into #temp (created_at,customer_id)
	(
		select CAST (MAX(a.action_time) as datetime) as date1, c.customer_id 
		from custmer_deletion_log as c,action_log as a 
		where [Status]='enable'
		and a.action_id=c.action_id 
		group by c.customer_id
	) 
	--pp add
 
	--SET NOCOUNT ON;
	SET @auto_status ='';
	IF(@status='auto')
	BEGIN
		SET @status ='disable';
		SET @auto_status ='1';

		insert into #Customer_AutoLog_Table (customer_id,locked_desc)
		(
			select customer.customer_id,@status 
			from customer,System_Log
			where customer.customer_id = System_Log.customer_id 
			and customer.[status] ='disable'
			and System_Log.reason != 'invalid_login'
			and System_Log.reason != 'lbs'
			and cast(System_Log.created_at as date) >= cast(@start_date as date)
			and cast(System_Log.created_at as date) <= cast(@end_date as date)
			and (
					customer.customer_id in 
					(
						select t.customer_id
						from #temp as t
						right join System_Log as s 
						on s.customer_id = t.customer_id
						group by t.created_at, t.customer_id,s.reason
						having CAST (MAX(s.created_at) as datetime) > CAST (MAX(t.created_at) as datetime)  
						and s.reason != 'invalid_login' and s.reason != 'lbs'
					) 
					OR 
					customer.customer_id not in 
					(
						select customer_id from #temp
					)
			)
		)
	END
	ELSE IF(@status='login')
	BEGIN
		Print('Login');
		SET @status ='disable';
		SET @auto_status ='2';

		insert into #Customer_AutoLog_Table (customer_id,locked_desc)
		(
			select customer.customer_id,@status 
			from customer,System_Log
			where customer.customer_id = System_Log.customer_id 
			and customer.[status] ='disable'
			and System_Log.reason = 'invalid_login'
			and cast(System_Log.created_at as date) >= cast(@start_date as date)
			and cast(System_Log.created_at as date) <= cast(@end_date as date)
			and (
				customer.customer_id in 
				(
					select t.customer_id
					from #temp as t
					right join System_Log as s 
					on s.customer_id = t.customer_id
					group by t.created_at, t.customer_id,s.reason
					having CAST (MAX(s.created_at) as datetime) > CAST (MAX(t.created_at) as datetime) 
					and s.reason = 'invalid_login'
				)
				OR 
				customer.customer_id not in 
				(
					select customer_id from #temp
				)
			)
		)
	END
	ELSE IF(@status='lbs')
	BEGIN
		Print('lbs');
		SET @status ='disable';
		SET @auto_status ='3';

		insert into #Customer_AutoLog_Table (customer_id,locked_desc)
		(
			select customer.customer_id,@status 
			from customer,System_Log
			where customer.customer_id = System_Log.customer_id 
			and customer.[status] ='disable'
			and System_Log.reason = 'lbs'
			and cast(System_Log.created_at as date) >= cast(@start_date as date)
			and cast(System_Log.created_at as date) <= cast(@end_date as date)
			and (
				customer.customer_id in 
				(
					select t.customer_id
					from #temp as t
					right join System_Log as s 
					on s.customer_id = t.customer_id
					group by t.created_at, t.customer_id,s.reason
					having CAST (MAX(s.created_at) as datetime) > CAST (MAX(t.created_at) as datetime) 
					and s.reason = 'lbs'
				)
				OR 
				customer.customer_id not in 
				(
					select customer_id from #temp
				)
			)
		)
	END
	ELSE IF(@status='IP')
	BEGIN
		Print('IP');
		SET @status ='disable';
		SET @auto_status ='4';

		insert into #Customer_AutoLog_Table (customer_id,locked_desc)
		(
			select customer.customer_id,@status 
			from customer,System_Log
			where customer.customer_id = System_Log.customer_id 
			and customer.status ='disable'
			and System_Log.reason = 'SameIP_SameCode'
			and cast(System_Log.created_at as date) >= cast(@start_date as date)
			and cast(System_Log.created_at as date) <= cast(@end_date as date)
			and (
				customer.customer_id in 
				(
					select t.customer_id
					from #temp as t
					right join System_Log as s 
					on s.customer_id = t.customer_id
					group by t.created_at, t.customer_id,s.reason
					having CAST (MAX(s.created_at) as datetime) > CAST (MAX(t.created_at) as datetime) 
					and s.reason = 'SameIP_SameCode'
				)
			OR 
				customer.customer_id not in 
				(
					select customer_id from #temp
				)
			)
		)
	END
	ELSE IF(@status='tokenm')
	BEGIN
		Print('tokenm');
		SET @status ='disable';
		SET @auto_status ='5';

		insert into #Customer_AutoLog_Table (customer_id,locked_desc)
		(
			select customer.customer_id,locked_desc 
			from customer,System_Log
			where customer.customer_id = System_Log.customer_id 
			and customer.[status] ='disable'
			and System_Log.reason = 'Token_M'
			and cast(System_Log.created_at as date) >= cast(@start_date as date)
			and cast(System_Log.created_at as date) <= cast(@end_date as date)
			and (
				customer.customer_id in 
				(
					select t.customer_id
					from #temp as t
					right join System_Log as s 
					on s.customer_id = t.customer_id
					group by t.created_at, t.customer_id,s.reason
					having CAST (MAX(s.created_at) as datetime) > CAST (MAX(t.created_at) as datetime) 
					and s.reason = 'Token_M'
				)
				OR 
				customer.customer_id not in 
				(
					select customer_id from #temp
				)
			)
		)
	END
	ELSE IF(@status='multipleinstalls')
	BEGIN
		Print('multipleinstalls');
		SET @status ='disable';
		SET @auto_status ='5';

		insert into #Customer_AutoLog_Table (customer_id,locked_desc)
		(
			select customer.customer_id,locked_desc 
			from customer,System_Log
			where customer.customer_id = System_Log.customer_id 
			and customer.[status] ='disable'
			and System_Log.reason = 'multipleinstalls'
			and cast(System_Log.created_at as date) >= cast(@start_date as date)
			and cast(System_Log.created_at as date) <= cast(@end_date as date)
			and (
				customer.customer_id in 
				(
					select t.customer_id
					from #temp as t
					right join System_Log as s 
					on s.customer_id = t.customer_id
					group by t.created_at, t.customer_id,s.reason
					having CAST (MAX(s.created_at) as datetime) > CAST (MAX(t.created_at) as datetime) 
					and s.reason = 'multipleinstalls'
				)
				OR 
				customer.customer_id not in 
				(
					select customer_id from #temp
				)
			)
		)
	END

	set @start_date = CAST(@start_date as date);
	set @end_date = CAST(@end_date as date);

	IF (@start_date IS NOT NULL AND @end_date IS NOT NULL AND @start_date!='' AND @end_date !='') 
	BEGIN
		--------------------------------Customer_id is not null---------------------------------------
		IF(@customer_id IS NOT NULL AND @customer_id != '')    
		BEGIN
			--------------------------------IP Is not null ---------------------------------------
			IF(@ip_address is not null and @ip_address !='')
			BEGIN 
				;WITH customer_temp AS
				(
					SELECT customer.customer_id,customer.first_name,customer.last_name,ip_address,ip_scanned,
					ROW_NUMBER() OVER(ORDER BY customer.customer_id DESC) as intRow, 
					COUNT(customer.customer_id) OVER() AS total_count ,    
					customer.email ,temp.locked_desc as [status],customer.WID, cusGroup.group_name as [group] 
					from customer 
					join customer_group as cusGroup
					on customer.group_id = cusGroup.group_id
					and (@group_id is null or cusGroup.group_id = @group_id
					or cusGroup.group_id = @imob_group_id1 or cusGroup.group_id = @imob_group_id2 
					or cusGroup.group_id = @imob_group_id3 or cusGroup.group_id = @imob_group_id4
					or cusGroup.group_id = @imob_group_id5 or cusGroup.group_id = @imob_group_id6)
					inner join #Customer_AutoLog_Table as temp on customer.customer_id = temp.customer_id
					where customer.customer_id= @customer_id 
					AND customer.ip_address like '%'+ @ip_address+'%'
					AND (@wid is null or customer.WID like '%'+ @wid+'%')
					AND (@ip_scanned is null or customer.ip_scanned like '%'+ @ip_scanned+'%')
					AND (@customer_name is null  or Lower(customer.first_name +' '+ customer.last_name) LIKE Lower( '%'+@customer_name +'%'))
					AND (@customer_email is null  or Lower(customer.email) LIKE Lower('%'+LTRIM(RTRIM(@customer_email))+'%'))   
					AND (@status is null  or Lower(customer.[status]) LIKE Lower(@status+'%'))
				),
				------------------------------
				Trip_Points_temp As
				(         
					select customer_id,SUM(wink_canid_earned_points.total_points) As trip_points 
					from wink_canid_earned_points
					where customer_id = @customer_id
					and  CAST (wink_canid_earned_points.created_at AS Date )       
					BETWEEN CAST (@start_date AS date) and CAST (@end_date AS date)   
					GROUP By customer_id
				), 
							 -----------------------------------
								
							 customer_earned_points_temp as 
							(Select ISNULL(SUM
							(customer_earned_points.points),0) as Total_QR_Scan_Points,customer_id,
							 COUNT(*) as No_Of_Scan
							 from customer_earned_points 
							 where customer_id = @customer_id and   
							 CONVERT(CHAR (10),customer_earned_points.created_at,111)       
							  BETWEEN CONVERT(CHAR(10),@start_date,111) and 
							  CONVERT(CHAR(10),@end_date,111) 
							  Group by customer_id)
							  ,
							  --------------------------------------
							   net_Points_temp as 
								(select wink_net_canid_earned_points.customer_id,SUM(wink_net_canid_earned_points.total_points) As total_nets_points 
								from wink_net_canid_earned_points      
								 where   customer_id = @customer_id and  
								 CAST (wink_net_canid_earned_points.created_at AS Date ) BETWEEN CAST (@start_date AS date)  and CAST (@end_date AS date)       
  								 GROUP By wink_net_canid_earned_points.customer_id     
					      
								 ) ,
						 
								------------------------------------- 
						
						
							  alltime_total_evoucher_temp as
							  (select customer_id, COUNT(*)  AS alltime_total_evoucher 

								,SUM(redeemed_winks) as alltime_Redeemed_Winks  from customer_earned_evouchers  
								where  customer_id = @customer_id and       
								CAST(customer_earned_evouchers.created_at AS DATE) <= @end_date 
								group by customer_id),
			            
								--------------------------------
			          
								alltime_total_expired_evoucher_temp as
								(select customer_id, COUNT(*)  AS alltime_total_expired_evoucher 

								from customer_earned_evouchers  
								where  customer_id = @customer_id and       
								CAST(customer_earned_evouchers.created_at AS DATE) <= @end_date 
								AND CAST (customer_earned_evouchers.expired_date AS  Date) <= CAST (@CURRENT_DATETIME AS Date)   
								and used_status =0
								group by customer_id),
								------------------------------------------
								 alltime_Total_Redeemed_eVouchers_temp as
								(Select customer_id,COUNT(*) As 

								 alltime_total_Redeemed_evoucher from customer_earned_evouchers 
								 where customer_id = @customer_id and
								  customer_earned_evouchers.used_status =1 
								  AND Cast (created_at as date) <= cast(@end_date as date)
									group by customer_id
									) 
									,
								-----------------------------------------------------  
					  
							  alltime_customer_earned_points_temp as 
							  (Select ISNULL(SUM (customer_earned_points.points),0) as alltime_Total_QR_Points
							   ,customer_id
							   from customer_earned_points
							   where  CAST(customer_earned_points.created_at as date) <= CAST(@end_date as date) 
								Group by customer_earned_points.customer_id 
			       			  ),
			       			  -----------------------------------
			       				 alltime_Total_Trip_Points_temp as
								 (      
					           
								 select customer_id,SUM(wink_canid_earned_points.total_points) As alltime_Total_Trip_Points

								 from wink_canid_earned_points      
								 where customer_id = @customer_id and  
								 CAST (wink_canid_earned_points.created_at AS date) <= CAST (@end_date AS date)       
								 GROUP By customer_id      
					      
								 ),
			
								 -----------------------------------------
								 all_time_total_net_points_temp as 
								  (      
									select wink_net_canid_earned_points.customer_id,SUM(wink_net_canid_earned_points.total_points)  As all_time_nets_points 
									from wink_net_canid_earned_points      
									 where  customer_id = @customer_id and 
									  CAST (wink_net_canid_earned_points.created_at AS Date ) <= CAST (@end_date AS date)     

								   GROUP By wink_net_canid_earned_points.customer_id   
								 ),
								 ---------------------------------------    
			       	    
								  alltime_Confiscated_Points_temp as 
								 (      
					      
								 Select customer_id,ISNULL(SUM(points_confiscated_detail.confiscated_points),0)  AS alltime_Confiscated_Points  
								 from 
								 points_confiscated_detail       
								 where customer_id = @customer_id and   CAST (points_confiscated_detail.created_at AS date)<=CAST (@end_date AS date)
						 
								  GROUP By customer_id      
					      
								 ),
								 ---------------------------------------
								   alltime_Redeemed_Points_temp as    
								 (      
					      
								 Select customer_id,ISNULL(SUM(customer_earned_winks.redeemed_points),0) AS alltime_Redeemed_Points  
								 from customer_earned_winks       
								 where customer_id = @customer_id and   
								 CAST (customer_earned_winks.created_at AS date) <= 
								 CAST (@end_date AS date)       


								  GROUP By customer_id        
					      
								 ) ,
						 
								 -------------------------------
								 alltime_Total_Winks_temp as 
									( Select customer_id,SUM(ISNULL(customer_earned_winks.total_winks,0))AS alltime_Total_Winks 
														
									from customer_earned_winks       
									where customer_id = @customer_id and 
									( CAST (customer_earned_winks.created_at AS date) <= CAST (@end_date AS date) )      
									GROUP By customer_earned_winks.customer_id   
									),
									----------------------------------
								alltime_Confiscated_Winks_temp as 
									 (      
						      
									 Select wink_confiscated_detail.customer_id,SUM(ISNULL(wink_confiscated_detail.total_winks,0)) AS alltime_Confiscated_Winks 
									 from wink_confiscated_detail       
									 where wink_confiscated_detail.customer_id = @customer_id and 
									 CAST(wink_confiscated_detail.created_at as date) <= CAST(@end_date as date)

									 GROUP By customer_id           
						     
									 ) , 	 
			       	  
			       	  
			       			 expired_eVouchers_temp as 
							(
					
							select COUNT(*) AS Expired_Evoucher,customer_id

							 from customer_earned_evouchers       
							where customer_id = @customer_id and     
							customer_earned_evouchers.used_status = 0 
							AND CAST(created_at AS DATE) 
							BETWEEN Cast (@start_date as DATE) AND       
							Cast (@end_date as DATE)
							AND CAST (expired_date AS Date) <= CAST(@CURRENT_DATETIME AS Date)   
			          
							Group By customer_id 
						        
							),
			        
						  Total_Winks_temp as
						  (Select customer_id,SUM(ISNULL(customer_earned_winks.total_winks,0)) as Total_Winks
 
								  from customer_earned_winks       
								 where  customer_id = @customer_id and    
								 CAST (customer_earned_winks.created_at AS date)  BETWEEN CAST (@start_date AS date)  and CAST (@end_date AS date)       
								 GROUP By customer_earned_winks.customer_id    
						  ),
							 ----------------------------------------
							total_eVoucher_temp AS 
							(select COUNT(*) AS Total_eVoucher,SUM(redeemed_winks) as Redeemed_Winks ,
							customer_id 
							 from customer_earned_evouchers       
							 where customer_id = @customer_id and   
							 CAST(customer_earned_evouchers.created_at AS DATE) 
							 BETWEEN CAST(@start_date as date) AND Cast(@end_date as date)
							  group by customer_id 
							  ),
							   total_winks_confiscated_temp as
							(      
		      
							Select customer_id, SUM(ISNULL(wink_confiscated_detail.total_winks,0)) as total_winks_confiscated 

							from  wink_confiscated_detail where customer_id = @customer_id and     
								CAST (wink_confiscated_detail.created_at AS date) BETWEEN CAST (@start_date AS date)  and CAST (@end_date AS date)       
							  GROUP By wink_confiscated_detail.customer_id
							),
							 total_points_confiscated_temp as 
								(      
		      
								 Select customer_id,SUM(ISNULL(points_confiscated_detail.confiscated_points,0))  AS total_points_confiscated from 
								 points_confiscated_detail where   customer_id = @customer_id and CAST (points_confiscated_detail.created_at AS date) 
								   BETWEEN CAST (@start_date AS date)  and CAST(@end_date AS date)       
									GROUP By points_confiscated_detail.customer_id      
							 ),
			       
								 --------------------------------------
							  customer_cic_points_temp as 
							(Select ISNULL(SUM(cic_table.total_points),0) as Total_CIC_Points,customer_id       
							 from cic_table 
							 where customer_id = @customer_id and   
							 CONVERT(CHAR (10),cic_table.created_at,111)       
							  BETWEEN CONVERT(CHAR(10),@start_date,111) and 
							  CONVERT(CHAR(10),@end_date,111) 
							  Group by customer_id),
					  
							  --------------------------------------
							   alltime_cic_Points_temp as
								 (      
					           
								Select ISNULL(SUM(cic_table.total_points),0) as alltime_Total_CIC_Points,customer_id
						         
							 from cic_table 
							 where customer_id = @customer_id and   
							 CONVERT(CHAR (10),cic_table.created_at,111)       
							  <= CONVERT(CHAR(10),@end_date,111)  
					  
							  Group by customer_id    
					      
								 ),

							--------------winktag------------------------
							customer_winktag_points_temp as 
							(Select ISNULL(SUM(winktag.points),0) as Total_WINKTAG_Points,customer_id       
							from winktag_customer_earned_points as winktag 
							where customer_id = @customer_id and   
							CONVERT(CHAR (10),winktag.created_at,111)       
							BETWEEN CONVERT(CHAR(10),@start_date,111) and 
							CONVERT(CHAR(10),@end_date,111) 
							Group by customer_id),

							--------------------------------------
							alltime_winktag_Points_temp as
							(      
		   
							Select ISNULL(SUM(winktag.points),0) as alltime_Total_WINKTag_Points,customer_id         
							from winktag_customer_earned_points as winktag  
							where customer_id = @customer_id and   
							CONVERT(CHAR (10),winktag.created_at,111)       
							<= CONVERT(CHAR(10),@end_date,111)  	  
							Group by customer_id),
					
							--------------Manual Points Insertion------------------------
							customer_misc_points_temp as 
							(
							Select ISNULL(SUM(misc.points),0) as Total_Misc_Points,customer_id       
							from winners_points as misc 
							where customer_id = @customer_id and
							CONVERT(CHAR (10),misc.created_at,111)       
							BETWEEN CONVERT(CHAR(10),@start_date,111) and 
							CONVERT(CHAR(10),@end_date,111) 
							Group by customer_id
							),

							 --------------------------------------
							alltime_misc_Points_temp as
							(      					           
							Select ISNULL(SUM(misc.points),0) as alltime_Total_Misc_Points,customer_id         
							from winners_points as misc  
							where customer_id = @customer_id and   
							CONVERT(CHAR (10),misc.created_at,111)       
							<= CONVERT(CHAR(10),@end_date,111)  
							Group by customer_id
							)
					  
			       
							select c.customer_id, first_name,last_name,email,[status],wid,[group], total_count,ip_address,ip_scanned,
							(ISNULL (Trip_Points,0)+  ISNULL(Total_QR_Scan_Points,0) 
							+  ISNULL (total_nets_points,0) 
					
							+  ISNULL (Total_CIC_Points,0)
							+ ISNULL (Total_WINKTAG_Points,0)
							+ ISNULL (Total_Misc_Points,0)
					
							) as total_points,
							  (ISNULL (alltime_total_evoucher,0)-  ISNULL (alltime_total_Redeemed_evoucher,0) - ISNULl (alltime_total_expired_evoucher,0)) as balanced_evouchers,  
							   ( 
								 (ISNULL(alltime_Total_QR_Points,0) 
								  + ISNULL ( alltime_Total_CIC_Points,0)
								  + ISNULL ( alltime_Total_WINKTag_Points,0)
								  + ISNULL ( alltime_Total_Misc_Points,0)
							   + ISNULL (alltime_Total_Trip_Points,0) 
							   + ISNULL ( all_time_nets_points,0))
							   - (ISNULL(alltime_Confiscated_Points,0)+ISNULL(alltime_Redeemed_Points,0)))as balanced_points,	    			    
					    
							   (ISNULL (alltime_Total_Winks,0)- ISNULL (alltime_Redeemed_Winks ,0 )-ISNULL(alltime_Confiscated_Winks,0)) as balanced_winks,
							   ISNULl (Expired_Evoucher,0) as Expired_Evoucher,
							   ISNULL (Total_eVoucher,0) as Total_eVoucher , 
							   ISNULL (No_Of_Scan,0) as No_Of_Scan,
							   ISNULL(Total_Winks,0) as Total_Winks,
							   ISNULL (total_winks_confiscated,0) as total_winks_confiscated,
							   ISNULL (total_points_confiscated,0) as total_points_confiscated,
							   ISNULL (Redeemed_winks,0) as Redeemed_winks
					   
					 			  
					 
							  from customer_temp as c left join 
							 customer_earned_points_temp as points on
							 c.customer_id = points.customer_id
							  left join Trip_Points_temp as d
							 on d.customer_id = c.customer_id
							  left join net_Points_temp as e
							 on e.customer_id = c.customer_id
							 left join Total_Winks_temp as f
							 on f.customer_id = c.customer_id
							 left join alltime_total_evoucher_temp as g
							 on g.customer_id = c.customer_id
							  left join alltime_Total_Redeemed_eVouchers_temp as h
							 on h.customer_id = c.customer_id
							  left join alltime_total_expired_evoucher_temp as i
							 on i.customer_id = c.customer_id
							 left join alltime_customer_earned_points_temp as j
							 on c.customer_id = j.customer_id
							 left join alltime_Total_Trip_Points_temp as k
							 on k.customer_id = c.customer_id
							 left join all_time_total_net_points_temp as l
							 on l.customer_id = c.customer_id
							  left join alltime_Confiscated_Points_temp as o
							 on o.customer_id = c.customer_id
							  left join alltime_Redeemed_Points_temp as p
							 on p.customer_id = c.customer_id
							  left join alltime_Total_Winks_temp as q
							 on q.customer_id = c.customer_id
							  left join alltime_Confiscated_Winks_temp as r
							 on r.customer_id = c.customer_id
							 left join expired_eVouchers_temp as s
							 on s.customer_id = c.customer_id
							 left join total_eVoucher_temp as t
							 on t.customer_id = c.customer_id
							 left join total_winks_confiscated_temp as u
							 on c.customer_id = u.customer_id
							 left join total_points_confiscated_temp as v
							 on c.customer_id = v.customer_id
							 left join customer_cic_points_temp as w
							 on c.customer_id = w.customer_id
							  left join alltime_cic_Points_temp as x
							 on c.customer_id = x.customer_id
							left join customer_winktag_points_temp as y
							on c.customer_id = y.customer_id
							left join alltime_winktag_Points_temp as z
							on c.customer_id = z.customer_id
							left join customer_misc_points_temp as a
							 on c.customer_id = a.customer_id
							 left join alltime_misc_Points_temp as b
							 on c.customer_id = b.customer_id
										 
							 group by c.customer_id
							 ,first_name,last_name,email, [status],ip_address,ip_scanned,wid, [group],    
							  Total_QR_Scan_Points, Trip_Points,total_nets_points,
							  alltime_total_evoucher, alltime_total_Redeemed_evoucher,alltime_total_expired_evoucher,
							  alltime_Total_QR_Points, all_time_nets_points,alltime_Total_Trip_Points,
							  alltime_Redeemed_Points,alltime_Confiscated_Points,
							  alltime_Total_Winks,alltime_Redeemed_Winks,alltime_Confiscated_Winks,
							  Expired_Evoucher,Total_eVoucher,      
							  No_Of_Scan,     
							  Total_Winks,   
							  total_count,
							  total_winks_confiscated,
							  total_points_confiscated,
							  Redeemed_winks,
							  alltime_Total_CIC_Points,
							  Total_CIC_Points,
							  alltime_Total_WINKTag_Points,
							  Total_WINKTAG_Points,
							  alltime_Total_Misc_Points,
							  Total_Misc_Points
					  
					  
							   order by No_Of_Scan desc
			END
			------------------------------ Ip scanned is not null -----------------------
			ELSE IF (@ip_scanned is not null and @ip_scanned !='')		  
			BEGIN 
				;WITH customer_temp AS
				(
                    
					SELECT customer.customer_id,customer.first_name,customer.last_name,ip_address,ip_scanned,
					ROW_NUMBER() OVER(ORDER BY customer.customer_id DESC) as intRow, 
					COUNT(customer.customer_id) OVER() AS total_count ,    
					customer.email ,temp.locked_desc as [status],customer.WID, cusGroup.group_name as [group] 
					from customer 
					join customer_group as cusGroup
					on customer.group_id = cusGroup.group_id
					and (@group_id is null or cusGroup.group_id = @group_id
					or cusGroup.group_id = @imob_group_id1 or cusGroup.group_id = @imob_group_id2 
					or cusGroup.group_id = @imob_group_id3 or cusGroup.group_id = @imob_group_id4
					or cusGroup.group_id = @imob_group_id5 or cusGroup.group_id = @imob_group_id6)
					inner join #Customer_AutoLog_Table as temp on customer.customer_id = temp.customer_id
			      
					where customer.customer_id= @customer_id 
					and  customer.ip_scanned= @ip_scanned
					AND (@wid is null or customer.WID like '%'+ @wid+'%')
					AND (@customer_name is null  or Lower(customer.first_name +' '+ customer.last_name) LIKE Lower( '%'+@customer_name +'%'))
					AND (@customer_email is null  or Lower(customer.email) LIKE Lower('%'+LTRIM(RTRIM(@customer_email))+'%'))   
					AND (@status is null  or Lower(customer.[status]) LIKE Lower(@status+'%'))
					),
							------------------------------
							
							   Trip_Points_temp As
							(
				           
							 select customer_id,SUM(wink_canid_earned_points.total_points) As trip_points 
							 from wink_canid_earned_points      


							 where customer_id = @customer_id and     
					 
							  CAST (wink_canid_earned_points.created_at AS Date )       
							 BETWEEN CAST (@start_date AS date)  and CAST (@end_date AS date)   
							 GROUP By customer_id            
				         
							 )      
							 , 
							 -----------------------------------
								
							 customer_earned_points_temp as 
							(Select ISNULL(SUM
							(customer_earned_points.points),0) as Total_QR_Scan_Points,customer_id,
							 COUNT(*) as No_Of_Scan
							 from customer_earned_points 
							 where customer_id = @customer_id and   
							 CONVERT(CHAR (10),customer_earned_points.created_at,111)       
							  BETWEEN CONVERT(CHAR(10),@start_date,111) and 
							  CONVERT(CHAR(10),@end_date,111) 
							  Group by customer_id)
							  ,
							  --------------------------------------
							   net_Points_temp as 
								(select wink_net_canid_earned_points.customer_id,SUM(wink_net_canid_earned_points.total_points) As total_nets_points 
								from wink_net_canid_earned_points      
								 where   customer_id = @customer_id and  
								 CAST (wink_net_canid_earned_points.created_at AS Date ) BETWEEN CAST (@start_date AS date)  and CAST (@end_date AS date)       
  								 GROUP By wink_net_canid_earned_points.customer_id     
					      
								 ) ,
						 
								------------------------------------- 
						
						
							  alltime_total_evoucher_temp as
							  (select customer_id, COUNT(*)  AS alltime_total_evoucher 

								,SUM(redeemed_winks) as alltime_Redeemed_Winks  from customer_earned_evouchers  
								where  customer_id = @customer_id and       
								CAST(customer_earned_evouchers.created_at AS DATE) <= @end_date 
								group by customer_id),
			            
								--------------------------------
			          
								alltime_total_expired_evoucher_temp as
								(select customer_id, COUNT(*)  AS alltime_total_expired_evoucher 

								from customer_earned_evouchers  
								where  customer_id = @customer_id and       
								CAST(customer_earned_evouchers.created_at AS DATE) <= @end_date 
								AND CAST (customer_earned_evouchers.expired_date AS  Date) <= CAST (@CURRENT_DATETIME AS Date)   
								and used_status =0
								group by customer_id),
								------------------------------------------
								 alltime_Total_Redeemed_eVouchers_temp as
								(Select customer_id,COUNT(*) As 

								 alltime_total_Redeemed_evoucher from customer_earned_evouchers 
								 where customer_id = @customer_id and
								  customer_earned_evouchers.used_status =1 
								  AND Cast (created_at as date) <= cast(@end_date as date)
									group by customer_id
									) 
									,
								-----------------------------------------------------  
					  
							  alltime_customer_earned_points_temp as 
							  (Select ISNULL(SUM (customer_earned_points.points),0) as alltime_Total_QR_Points
							   ,customer_id
							   from customer_earned_points
							   where  CAST(customer_earned_points.created_at as date) <= CAST(@end_date as date) 
								Group by customer_earned_points.customer_id 
			       			  ),
			       			  -----------------------------------
			       				 alltime_Total_Trip_Points_temp as
								 (      
					           
								 select customer_id,SUM(wink_canid_earned_points.total_points) As alltime_Total_Trip_Points

								 from wink_canid_earned_points      
								 where customer_id = @customer_id and  
								 CAST (wink_canid_earned_points.created_at AS date) <= CAST (@end_date AS date)       
								 GROUP By customer_id      
					      
								 ),
			
								 -----------------------------------------
								 all_time_total_net_points_temp as 
								  (      
									select wink_net_canid_earned_points.customer_id,SUM(wink_net_canid_earned_points.total_points)  As all_time_nets_points 
									from wink_net_canid_earned_points      
									 where  customer_id = @customer_id and 
									  CAST (wink_net_canid_earned_points.created_at AS Date ) <= CAST (@end_date AS date)     

								   GROUP By wink_net_canid_earned_points.customer_id   
								 ),
								 ---------------------------------------    
			       	    
								  alltime_Confiscated_Points_temp as 
								 (      
					      
								 Select customer_id,ISNULL(SUM(points_confiscated_detail.confiscated_points),0)  AS alltime_Confiscated_Points  
								 from 
								 points_confiscated_detail       
								 where customer_id = @customer_id and   CAST (points_confiscated_detail.created_at AS date)<=CAST (@end_date AS date)
						 
								  GROUP By customer_id      
					      
								 ),
								 ---------------------------------------
								   alltime_Redeemed_Points_temp as    
								 (      
					      
								 Select customer_id,ISNULL(SUM(customer_earned_winks.redeemed_points),0) AS alltime_Redeemed_Points  
								 from customer_earned_winks       
								 where customer_id = @customer_id and   
								 CAST (customer_earned_winks.created_at AS date) <= 
								 CAST (@end_date AS date)       


								  GROUP By customer_id        
					      
								 ) ,
						 
								 -------------------------------
								 alltime_Total_Winks_temp as 
									( Select customer_id,SUM(ISNULL(customer_earned_winks.total_winks,0))AS alltime_Total_Winks 
														
									from customer_earned_winks       
									where customer_id = @customer_id and 
									( CAST (customer_earned_winks.created_at AS date) <= CAST (@end_date AS date) )      
									GROUP By customer_earned_winks.customer_id   
									),
									----------------------------------
								alltime_Confiscated_Winks_temp as 
									 (      
						      
									 Select wink_confiscated_detail.customer_id,SUM(ISNULL(wink_confiscated_detail.total_winks,0)) AS alltime_Confiscated_Winks 
									 from wink_confiscated_detail       
									 where wink_confiscated_detail.customer_id = @customer_id and 
									 CAST(wink_confiscated_detail.created_at as date) <= CAST(@end_date as date)

									 GROUP By customer_id           
						     
									 ) , 	 
			       	  
			       	  
			       			 expired_eVouchers_temp as 
							(
					
							select COUNT(*) AS Expired_Evoucher,customer_id

							 from customer_earned_evouchers       
							where customer_id = @customer_id and     
							customer_earned_evouchers.used_status = 0 
							AND CAST(created_at AS DATE) 
							BETWEEN Cast (@start_date as DATE) AND       
							Cast (@end_date as DATE)
							AND CAST (expired_date AS Date) <= CAST(@CURRENT_DATETIME AS Date)   
			          
							Group By customer_id 
						        
							),
			        
						  Total_Winks_temp as
						  (Select customer_id,SUM(ISNULL(customer_earned_winks.total_winks,0)) as Total_Winks
 
								  from customer_earned_winks       
								 where  customer_id = @customer_id and    
								 CAST (customer_earned_winks.created_at AS date)  BETWEEN CAST (@start_date AS date)  and CAST (@end_date AS date)       
								 GROUP By customer_earned_winks.customer_id    
						  ),
							 ----------------------------------------
							total_eVoucher_temp AS 
							(select COUNT(*) AS Total_eVoucher,SUM(redeemed_winks) as Redeemed_Winks ,
							customer_id 
							 from customer_earned_evouchers       
							 where customer_id = @customer_id and   
							 CAST(customer_earned_evouchers.created_at AS DATE) 
							 BETWEEN CAST(@start_date as date) AND Cast(@end_date as date)
							  group by customer_id 
							  ),
							   total_winks_confiscated_temp as
							(      
		      
							Select customer_id, SUM(ISNULL(wink_confiscated_detail.total_winks,0)) as total_winks_confiscated 

							from  wink_confiscated_detail where customer_id = @customer_id and     
								CAST (wink_confiscated_detail.created_at AS date) BETWEEN CAST (@start_date AS date)  and CAST (@end_date AS date)       
							  GROUP By wink_confiscated_detail.customer_id
							),
							 total_points_confiscated_temp as 
								(      
		      
								 Select customer_id,SUM(ISNULL(points_confiscated_detail.confiscated_points,0))  AS total_points_confiscated from 
								 points_confiscated_detail where   customer_id = @customer_id and CAST (points_confiscated_detail.created_at AS date) 
								   BETWEEN CAST (@start_date AS date)  and CAST(@end_date AS date)       
									GROUP By points_confiscated_detail.customer_id      
							 ),
			       
								 --------------------------------------
							  customer_cic_points_temp as 
							(Select ISNULL(SUM(cic_table.total_points),0) as Total_CIC_Points,customer_id       
							 from cic_table 
							 where customer_id = @customer_id and   
							 CONVERT(CHAR (10),cic_table.created_at,111)       
							  BETWEEN CONVERT(CHAR(10),@start_date,111) and 
							  CONVERT(CHAR(10),@end_date,111) 
							  Group by customer_id),
					  
							  --------------------------------------
							   alltime_cic_Points_temp as
								 (      
					           
								Select ISNULL(SUM(cic_table.total_points),0) as alltime_Total_CIC_Points,customer_id
						         
							 from cic_table 
							 where customer_id = @customer_id and   
							 CONVERT(CHAR (10),cic_table.created_at,111)       
							  <= CONVERT(CHAR(10),@end_date,111)  
					  
							  Group by customer_id    
					      
								 ),

							--------------winktag------------------------
							customer_winktag_points_temp as 
							(Select ISNULL(SUM(winktag.points),0) as Total_WINKTAG_Points,customer_id       
							from winktag_customer_earned_points as winktag 
							where customer_id = @customer_id and   
							CONVERT(CHAR (10),winktag.created_at,111)       
							BETWEEN CONVERT(CHAR(10),@start_date,111) and 
							CONVERT(CHAR(10),@end_date,111) 
							Group by customer_id),

							--------------------------------------
							alltime_winktag_Points_temp as
							(      
		   
							Select ISNULL(SUM(winktag.points),0) as alltime_Total_WINKTag_Points,customer_id         
							from winktag_customer_earned_points as winktag  
							where customer_id = @customer_id and   
							CONVERT(CHAR (10),winktag.created_at,111)       
							<= CONVERT(CHAR(10),@end_date,111)  	  
							Group by customer_id),
					
							--------------Manual Points Insertion------------------------
							customer_misc_points_temp as 
							(
							Select ISNULL(SUM(misc.points),0) as Total_Misc_Points,customer_id       
							from winners_points as misc 
							where customer_id = @customer_id and
							CONVERT(CHAR (10),misc.created_at,111)       
							BETWEEN CONVERT(CHAR(10),@start_date,111) and 
							CONVERT(CHAR(10),@end_date,111) 
							Group by customer_id
							),

							 --------------------------------------
							alltime_misc_Points_temp as
							(      					           
							Select ISNULL(SUM(misc.points),0) as alltime_Total_Misc_Points,customer_id         
							from winners_points as misc  
							where customer_id = @customer_id and   
							CONVERT(CHAR (10),misc.created_at,111)       
							<= CONVERT(CHAR(10),@end_date,111)  
							Group by customer_id
							)
					  
			       
							select c.customer_id, first_name,last_name,email,[status], total_count,ip_address,ip_scanned,wid, [group],
							(ISNULL (Trip_Points,0)+  ISNULL(Total_QR_Scan_Points,0) 
							+  ISNULL (total_nets_points,0) 
					
							+  ISNULL (Total_CIC_Points,0)
							+ ISNULL (Total_WINKTAG_Points,0)
							+ ISNULL (Total_Misc_Points,0)
					
							) as total_points,
							  (ISNULL (alltime_total_evoucher,0)-  ISNULL (alltime_total_Redeemed_evoucher,0) - ISNULl (alltime_total_expired_evoucher,0)) as balanced_evouchers,  
							   ( 
								 (ISNULL(alltime_Total_QR_Points,0) 
								  + ISNULL ( alltime_Total_CIC_Points,0)
								  + ISNULL ( alltime_Total_WINKTag_Points,0)
								  + ISNULL ( alltime_Total_Misc_Points,0)
							   + ISNULL (alltime_Total_Trip_Points,0) 
							   + ISNULL ( all_time_nets_points,0))
							   - (ISNULL(alltime_Confiscated_Points,0)+ISNULL(alltime_Redeemed_Points,0)))as balanced_points,	    			    
					    
							   (ISNULL (alltime_Total_Winks,0)- ISNULL (alltime_Redeemed_Winks ,0 )-ISNULL(alltime_Confiscated_Winks,0)) as balanced_winks,
							   ISNULl (Expired_Evoucher,0) as Expired_Evoucher,
							   ISNULL (Total_eVoucher,0) as Total_eVoucher , 
							   ISNULL (No_Of_Scan,0) as No_Of_Scan,
							   ISNULL(Total_Winks,0) as Total_Winks,
							   ISNULL (total_winks_confiscated,0) as total_winks_confiscated,
							   ISNULL (total_points_confiscated,0) as total_points_confiscated,
							   ISNULL (Redeemed_winks,0) as Redeemed_winks
					   
					 			  
					 
							  from customer_temp as c left join 
							 customer_earned_points_temp as points on
							 c.customer_id = points.customer_id
							  left join Trip_Points_temp as d
							 on d.customer_id = c.customer_id
							  left join net_Points_temp as e
							 on e.customer_id = c.customer_id
							 left join Total_Winks_temp as f
							 on f.customer_id = c.customer_id
							 left join alltime_total_evoucher_temp as g
							 on g.customer_id = c.customer_id
							  left join alltime_Total_Redeemed_eVouchers_temp as h
							 on h.customer_id = c.customer_id
							  left join alltime_total_expired_evoucher_temp as i
							 on i.customer_id = c.customer_id
							 left join alltime_customer_earned_points_temp as j
							 on c.customer_id = j.customer_id
							 left join alltime_Total_Trip_Points_temp as k
							 on k.customer_id = c.customer_id
							 left join all_time_total_net_points_temp as l
							 on l.customer_id = c.customer_id
							  left join alltime_Confiscated_Points_temp as o
							 on o.customer_id = c.customer_id
							  left join alltime_Redeemed_Points_temp as p
							 on p.customer_id = c.customer_id
							  left join alltime_Total_Winks_temp as q
							 on q.customer_id = c.customer_id
							  left join alltime_Confiscated_Winks_temp as r
							 on r.customer_id = c.customer_id
							 left join expired_eVouchers_temp as s
							 on s.customer_id = c.customer_id
							 left join total_eVoucher_temp as t
							 on t.customer_id = c.customer_id
							 left join total_winks_confiscated_temp as u
							 on c.customer_id = u.customer_id
							 left join total_points_confiscated_temp as v
							 on c.customer_id = v.customer_id
							 left join customer_cic_points_temp as w
							 on c.customer_id = w.customer_id
							  left join alltime_cic_Points_temp as x
							 on c.customer_id = x.customer_id
							left join customer_winktag_points_temp as y
							on c.customer_id = y.customer_id
							left join alltime_winktag_Points_temp as z
							on c.customer_id = z.customer_id
							left join customer_misc_points_temp as a
							 on c.customer_id = a.customer_id
							 left join alltime_misc_Points_temp as b
							 on c.customer_id = b.customer_id
										 
							 group by c.customer_id
							 ,first_name,last_name,email, [status],ip_address,ip_scanned,
							 wid, [group],     
							Total_QR_Scan_Points, Trip_Points,total_nets_points,
							alltime_total_evoucher, alltime_total_Redeemed_evoucher,alltime_total_expired_evoucher,
							alltime_Total_QR_Points, all_time_nets_points,alltime_Total_Trip_Points,
							alltime_Redeemed_Points,alltime_Confiscated_Points,
							alltime_Total_Winks,alltime_Redeemed_Winks,alltime_Confiscated_Winks,
							Expired_Evoucher,Total_eVoucher,      
							No_Of_Scan,     
							Total_Winks,   
							total_count,
							total_winks_confiscated,
							total_points_confiscated,
							Redeemed_winks,
							alltime_Total_CIC_Points,
							Total_CIC_Points,
							alltime_Total_WINKTag_Points,
							Total_WINKTAG_Points,
							alltime_Total_Misc_Points,
							Total_Misc_Points
							order by No_Of_Scan desc
			END
			---------------------------NO IP Filter -------------------------------------------- 
			ELSE   
			BEGIN 	
				;WITH customer_temp AS
				(
                    
					SELECT customer.customer_id,customer.first_name,customer.last_name,ip_address,ip_scanned,
					ROW_NUMBER() OVER(ORDER BY customer.customer_id DESC) as intRow, 
					COUNT(customer.customer_id) OVER() AS total_count ,    
					customer.email ,temp.locked_desc as [status],customer.WID, cusGroup.group_name as [group] from customer
					 join customer_group as cusGroup
					on customer.group_id = cusGroup.group_id
					and (@group_id is null or cusGroup.group_id = @group_id
					or cusGroup.group_id = @imob_group_id1 or cusGroup.group_id = @imob_group_id2 
					or cusGroup.group_id = @imob_group_id3 or cusGroup.group_id = @imob_group_id4
					or cusGroup.group_id = @imob_group_id5 or cusGroup.group_id = @imob_group_id6)
					inner join #Customer_AutoLog_Table as temp on customer.customer_id = temp.customer_id 
			      
					where customer.customer_id= @customer_id 
					AND (@wid is null or customer.WID like '%'+ @wid+'%')
					AND (@customer_name is null  or Lower(customer.first_name +' '+ customer.last_name) LIKE Lower( '%'+@customer_name +'%'))
					AND (@customer_email is null  or Lower(customer.email) LIKE Lower('%'+LTRIM(RTRIM(@customer_email))+'%'))   
					AND (@status is null  or Lower(customer.[status]) LIKE Lower(@status+'%'))
				),
						------------------------------
							
							Trip_Points_temp As
						(
				           
							select customer_id,SUM(wink_canid_earned_points.total_points) As trip_points 
							from wink_canid_earned_points      


							where customer_id = @customer_id and     
					 
							CAST (wink_canid_earned_points.created_at AS Date )       
							BETWEEN CAST (@start_date AS date)  and CAST (@end_date AS date)   
							GROUP By customer_id            
				         
							)      
							, 
							-----------------------------------
								
							customer_earned_points_temp as 
						(Select ISNULL(SUM
						(customer_earned_points.points),0) as Total_QR_Scan_Points,customer_id,
							COUNT(*) as No_Of_Scan
							from customer_earned_points 
							where customer_id = @customer_id and   
							CONVERT(CHAR (10),customer_earned_points.created_at,111)       
							BETWEEN CONVERT(CHAR(10),@start_date,111) and 
							CONVERT(CHAR(10),@end_date,111) 
							Group by customer_id)
							,
							--------------------------------------
							net_Points_temp as 
							(select wink_net_canid_earned_points.customer_id,SUM(wink_net_canid_earned_points.total_points) As total_nets_points 
							from wink_net_canid_earned_points      
								where   customer_id = @customer_id and  
								CAST (wink_net_canid_earned_points.created_at AS Date ) BETWEEN CAST (@start_date AS date)  and CAST (@end_date AS date)       
  								GROUP By wink_net_canid_earned_points.customer_id     
					      
								) ,
						 
							------------------------------------- 
						
						
							alltime_total_evoucher_temp as
							(select customer_id, COUNT(*)  AS alltime_total_evoucher 

							,SUM(redeemed_winks) as alltime_Redeemed_Winks  from customer_earned_evouchers  
							where  customer_id = @customer_id and       
							CAST(customer_earned_evouchers.created_at AS DATE) <= @end_date 
							group by customer_id),
			            
							--------------------------------
			          
							alltime_total_expired_evoucher_temp as
							(select customer_id, COUNT(*)  AS alltime_total_expired_evoucher 

							from customer_earned_evouchers  
							where  customer_id = @customer_id and       
							CAST(customer_earned_evouchers.created_at AS DATE) <= @end_date 
							AND CAST (customer_earned_evouchers.expired_date AS  Date) <= CAST (@CURRENT_DATETIME AS Date)   
							and used_status =0
							group by customer_id),
							------------------------------------------
								alltime_Total_Redeemed_eVouchers_temp as
							(Select customer_id,COUNT(*) As 

								alltime_total_Redeemed_evoucher from customer_earned_evouchers 
								where customer_id = @customer_id and
								customer_earned_evouchers.used_status =1 
								AND Cast (created_at as date) <= cast(@end_date as date)
								group by customer_id
								) 
								,
							-----------------------------------------------------  
					  
							alltime_customer_earned_points_temp as 
							(Select ISNULL(SUM (customer_earned_points.points),0) as alltime_Total_QR_Points
							,customer_id
							from customer_earned_points
							where  CAST(customer_earned_points.created_at as date) <= CAST(@end_date as date) 
							Group by customer_earned_points.customer_id 
			       			),
			       			-----------------------------------
			       				alltime_Total_Trip_Points_temp as
								(      
					           
								select customer_id,SUM(wink_canid_earned_points.total_points) As alltime_Total_Trip_Points

								from wink_canid_earned_points      
								where customer_id = @customer_id and  
								CAST (wink_canid_earned_points.created_at AS date) <= CAST (@end_date AS date)       
								GROUP By customer_id      
					      
								),
			
								-----------------------------------------
								all_time_total_net_points_temp as 
								(      
								select wink_net_canid_earned_points.customer_id,SUM(wink_net_canid_earned_points.total_points)  As all_time_nets_points 
								from wink_net_canid_earned_points      
									where  customer_id = @customer_id and 
									CAST (wink_net_canid_earned_points.created_at AS Date ) <= CAST (@end_date AS date)     

								GROUP By wink_net_canid_earned_points.customer_id   
								),
								---------------------------------------    
			       	    
								alltime_Confiscated_Points_temp as 
								(      
					      
								Select customer_id,ISNULL(SUM(points_confiscated_detail.confiscated_points),0)  AS alltime_Confiscated_Points  
								from 
								points_confiscated_detail       
								where customer_id = @customer_id and   CAST (points_confiscated_detail.created_at AS date)<=CAST (@end_date AS date)
						 
								GROUP By customer_id      
					      
								),
								---------------------------------------
								alltime_Redeemed_Points_temp as    
								(      
					      
								Select customer_id,ISNULL(SUM(customer_earned_winks.redeemed_points),0) AS alltime_Redeemed_Points  
								from customer_earned_winks       
								where customer_id = @customer_id and   
								CAST (customer_earned_winks.created_at AS date) <= 
								CAST (@end_date AS date)       


								GROUP By customer_id        
					      
								) ,
						 
								-------------------------------
								alltime_Total_Winks_temp as 
								( Select customer_id,SUM(ISNULL(customer_earned_winks.total_winks,0))AS alltime_Total_Winks 
														
								from customer_earned_winks       
								where customer_id = @customer_id and 
								( CAST (customer_earned_winks.created_at AS date) <= CAST (@end_date AS date) )      
								GROUP By customer_earned_winks.customer_id   
								),
								----------------------------------
							alltime_Confiscated_Winks_temp as 
									(      
						      
									Select wink_confiscated_detail.customer_id,SUM(ISNULL(wink_confiscated_detail.total_winks,0)) AS alltime_Confiscated_Winks 
									from wink_confiscated_detail       
									where wink_confiscated_detail.customer_id = @customer_id and 
									CAST(wink_confiscated_detail.created_at as date) <= CAST(@end_date as date)

									GROUP By customer_id           
						     
									) , 	 
			       	  
			       	  
			       			expired_eVouchers_temp as 
						(
					
						select COUNT(*) AS Expired_Evoucher,customer_id

							from customer_earned_evouchers       
						where customer_id = @customer_id and     
						customer_earned_evouchers.used_status = 0 
						AND CAST(created_at AS DATE) 
						BETWEEN Cast (@start_date as DATE) AND       
						Cast (@end_date as DATE)
						AND CAST (expired_date AS Date) <= CAST(@CURRENT_DATETIME AS Date)   
			          
						Group By customer_id 
						        
						),
			        
						Total_Winks_temp as
						(Select customer_id,SUM(ISNULL(customer_earned_winks.total_winks,0)) as Total_Winks
 
								from customer_earned_winks       
								where  customer_id = @customer_id and    
								CAST (customer_earned_winks.created_at AS date)  BETWEEN CAST (@start_date AS date)  and CAST (@end_date AS date)       
								GROUP By customer_earned_winks.customer_id    
						),
							----------------------------------------
						total_eVoucher_temp AS 
						(select COUNT(*) AS Total_eVoucher,SUM(redeemed_winks) as Redeemed_Winks ,
						customer_id 
							from customer_earned_evouchers       
							where customer_id = @customer_id and   
							CAST(customer_earned_evouchers.created_at AS DATE) 
							BETWEEN CAST(@start_date as date) AND Cast(@end_date as date)
							group by customer_id 
							),
							total_winks_confiscated_temp as
						(      
		      
						Select customer_id, SUM(ISNULL(wink_confiscated_detail.total_winks,0)) as total_winks_confiscated 

						from  wink_confiscated_detail where customer_id = @customer_id and     
							CAST (wink_confiscated_detail.created_at AS date) BETWEEN CAST (@start_date AS date)  and CAST (@end_date AS date)       
							GROUP By wink_confiscated_detail.customer_id
						),
							total_points_confiscated_temp as 
							(      
		      
								Select customer_id,SUM(ISNULL(points_confiscated_detail.confiscated_points,0))  AS total_points_confiscated from 
								points_confiscated_detail where   customer_id = @customer_id and CAST (points_confiscated_detail.created_at AS date) 
								BETWEEN CAST (@start_date AS date)  and CAST(@end_date AS date)       
								GROUP By points_confiscated_detail.customer_id      
							),
			       
							--------------------------------------
							customer_cic_points_temp as 
						(Select ISNULL(SUM(cic_table.total_points),0) as Total_CIC_Points,customer_id       
							from cic_table 
							where customer_id = @customer_id and   
							CONVERT(CHAR (10),cic_table.created_at,111)       
							BETWEEN CONVERT(CHAR(10),@start_date,111) and 
							CONVERT(CHAR(10),@end_date,111) 
							Group by customer_id),
					  
							--------------------------------------
							alltime_cic_Points_temp as
								(      
					           
							Select ISNULL(SUM(cic_table.total_points),0) as alltime_Total_CIC_Points,customer_id
						         
							from cic_table 
							where customer_id = @customer_id and   
							CONVERT(CHAR (10),cic_table.created_at,111)       
							<= CONVERT(CHAR(10),@end_date,111)  
					  
							Group by customer_id    
					      
								),

						--------------winktag------------------------
						customer_winktag_points_temp as 
						(Select ISNULL(SUM(winktag.points),0) as Total_WINKTAG_Points,customer_id       
						from winktag_customer_earned_points as winktag 
						where customer_id = @customer_id and   
						CONVERT(CHAR (10),winktag.created_at,111)       
						BETWEEN CONVERT(CHAR(10),@start_date,111) and 
						CONVERT(CHAR(10),@end_date,111) 
						Group by customer_id),

						--------------------------------------
						alltime_winktag_Points_temp as
						(      
		   
						Select ISNULL(SUM(winktag.points),0) as alltime_Total_WINKTag_Points,customer_id         
						from winktag_customer_earned_points as winktag  
						where customer_id = @customer_id and   
						CONVERT(CHAR (10),winktag.created_at,111)       
						<= CONVERT(CHAR(10),@end_date,111)  	  
						Group by customer_id),
					
						--------------Manual Points Insertion------------------------
						customer_misc_points_temp as 
						(
						Select ISNULL(SUM(misc.points),0) as Total_Misc_Points,customer_id       
						from winners_points as misc 
						where customer_id = @customer_id and
						CONVERT(CHAR (10),misc.created_at,111)       
						BETWEEN CONVERT(CHAR(10),@start_date,111) and 
						CONVERT(CHAR(10),@end_date,111) 
						Group by customer_id
						),

							--------------------------------------
						alltime_misc_Points_temp as
						(      					           
						Select ISNULL(SUM(misc.points),0) as alltime_Total_Misc_Points,customer_id         
						from winners_points as misc  
						where customer_id = @customer_id and   
						CONVERT(CHAR (10),misc.created_at,111)       
						<= CONVERT(CHAR(10),@end_date,111)  
						Group by customer_id
						)

					  
			       
						select c.customer_id, first_name,last_name,email,status, total_count,ip_address,ip_scanned,wid, [group],
						(ISNULL (Trip_Points,0)+  ISNULL(Total_QR_Scan_Points,0) 
						+  ISNULL (total_nets_points,0) 
					
						+  ISNULL (Total_CIC_Points,0)
						+ ISNULL (Total_WINKTAG_Points,0)
						+ ISNULL (Total_Misc_Points,0)
						) as total_points,
							(ISNULL (alltime_total_evoucher,0)-  ISNULL (alltime_total_Redeemed_evoucher,0) - ISNULl (alltime_total_expired_evoucher,0)) as balanced_evouchers,  
							( 
								(ISNULL(alltime_Total_QR_Points,0) 
								+ ISNULL ( alltime_Total_CIC_Points,0)
								+ ISNULL ( alltime_Total_WINKTag_Points,0)
								+ ISNULL ( alltime_Total_Misc_Points,0)
							+ ISNULL (alltime_Total_Trip_Points,0) 
							+ ISNULL ( all_time_nets_points,0))
							- (ISNULL(alltime_Confiscated_Points,0)+ISNULL(alltime_Redeemed_Points,0)))as balanced_points,	    			    
					    
							(ISNULL (alltime_Total_Winks,0)- ISNULL (alltime_Redeemed_Winks ,0 )-ISNULL(alltime_Confiscated_Winks,0)) as balanced_winks,
							ISNULl (Expired_Evoucher,0) as Expired_Evoucher,
							ISNULL (Total_eVoucher,0) as Total_eVoucher , 
							ISNULL (No_Of_Scan,0) as No_Of_Scan,
							ISNULL(Total_Winks,0) as Total_Winks,
							ISNULL (total_winks_confiscated,0) as total_winks_confiscated,
							ISNULL (total_points_confiscated,0) as total_points_confiscated,
							ISNULL (Redeemed_winks,0) as Redeemed_winks
					   
					 			  
					 
							from customer_temp as c left join 
							customer_earned_points_temp as points on
							c.customer_id = points.customer_id
							left join Trip_Points_temp as d
							on d.customer_id = c.customer_id
							left join net_Points_temp as e
							on e.customer_id = c.customer_id
							left join Total_Winks_temp as f
							on f.customer_id = c.customer_id
							left join alltime_total_evoucher_temp as g
							on g.customer_id = c.customer_id
							left join alltime_Total_Redeemed_eVouchers_temp as h
							on h.customer_id = c.customer_id
							left join alltime_total_expired_evoucher_temp as i
							on i.customer_id = c.customer_id
							left join alltime_customer_earned_points_temp as j
							on c.customer_id = j.customer_id
							left join alltime_Total_Trip_Points_temp as k
							on k.customer_id = c.customer_id
							left join all_time_total_net_points_temp as l
							on l.customer_id = c.customer_id
							left join alltime_Confiscated_Points_temp as o
							on o.customer_id = c.customer_id
							left join alltime_Redeemed_Points_temp as p
							on p.customer_id = c.customer_id
							left join alltime_Total_Winks_temp as q
							on q.customer_id = c.customer_id
							left join alltime_Confiscated_Winks_temp as r
							on r.customer_id = c.customer_id
							left join expired_eVouchers_temp as s
							on s.customer_id = c.customer_id
							left join total_eVoucher_temp as t
							on t.customer_id = c.customer_id
							left join total_winks_confiscated_temp as u
							on c.customer_id = u.customer_id
							left join total_points_confiscated_temp as v
							on c.customer_id = v.customer_id
							left join customer_cic_points_temp as w
							on c.customer_id = w.customer_id
							left join alltime_cic_Points_temp as x
							on c.customer_id = x.customer_id
							left join customer_winktag_points_temp as y
						on c.customer_id = y.customer_id
						left join alltime_winktag_Points_temp as z
						on c.customer_id = z.customer_id
						left join customer_misc_points_temp as a
							on c.customer_id = a.customer_id
							left join alltime_misc_Points_temp as b
							on c.customer_id = b.customer_id
										 
							group by c.customer_id
							,first_name,last_name,email, status,ip_address,ip_scanned,wid, [group],     
							Total_QR_Scan_Points, Trip_Points,total_nets_points,
							alltime_total_evoucher, alltime_total_Redeemed_evoucher,alltime_total_expired_evoucher,
							alltime_Total_QR_Points, all_time_nets_points,alltime_Total_Trip_Points,
							alltime_Redeemed_Points,alltime_Confiscated_Points,
							alltime_Total_Winks,alltime_Redeemed_Winks,alltime_Confiscated_Winks,
							Expired_Evoucher,Total_eVoucher,      
							No_Of_Scan,     
							Total_Winks,   
							total_count,
							total_winks_confiscated,
							total_points_confiscated,
							Redeemed_winks,
							alltime_Total_CIC_Points,
							Total_CIC_Points,
							alltime_Total_WINKTag_Points,
							Total_WINKTAG_Points,
							alltime_Total_Misc_Points,
							Total_Misc_Points
					  
					  
							order by No_Of_Scan desc
			END
		END
		----------------------------End Filter Customer ID
		ELSE
		BEGIN
			--------------------------------IP Is not null ---------------------------------------
			IF(@ip_address is not null and @ip_address !='')
			BEGIN
				;WITH customer_temp AS
				(
                    
					SELECT customer.customer_id,customer.first_name,customer.last_name,ip_address,ip_scanned,
					ROW_NUMBER() OVER(ORDER BY customer.customer_id DESC) as intRow, 
					COUNT(customer.customer_id) OVER() AS total_count ,    
					customer.email ,temp.locked_desc as [status],customer.WID, cusGroup.group_name as [group] from customer 
					join customer_group as cusGroup
					on customer.group_id = cusGroup.group_id
					and (@group_id is null or cusGroup.group_id = @group_id
					or cusGroup.group_id = @imob_group_id1 or cusGroup.group_id = @imob_group_id2 
					or cusGroup.group_id = @imob_group_id3 or cusGroup.group_id = @imob_group_id4
					or cusGroup.group_id = @imob_group_id5 or cusGroup.group_id = @imob_group_id6)
					inner join #Customer_AutoLog_Table as temp on customer.customer_id = temp.customer_id
			      
					where customer.ip_address like '%'+ @ip_address+'%'
					AND (@ip_scanned is null or customer.ip_scanned like '%'+ @ip_scanned+'%')
					AND (@wid is null or customer.WID like '%'+ @wid+'%')
					AND (@customer_name is null  or Lower(customer.first_name +' '+ customer.last_name) LIKE Lower( '%'+@customer_name +'%'))
					AND (@customer_email is null  or Lower(customer.email) LIKE Lower('%'+LTRIM(RTRIM(@customer_email))+'%'))   
					AND (@status is null  or Lower(customer.[status]) LIKE Lower(@status+'%'))
				),
				------------------------------
							
								Trip_Points_temp As
							(
				           
								select customer_id,SUM(wink_canid_earned_points.total_points) As trip_points 
								from wink_canid_earned_points      


								where   
					 
								CAST (wink_canid_earned_points.created_at AS Date )       
								BETWEEN CAST (@start_date AS date)  and CAST (@end_date AS date)   
								GROUP By customer_id            
				         
								)      
								, 
								-----------------------------------
								
								customer_earned_points_temp as 
							(Select ISNULL(SUM
							(customer_earned_points.points),0) as Total_QR_Scan_Points,customer_id,
								COUNT(*) as No_Of_Scan
								from customer_earned_points 
								where   
								CONVERT(CHAR (10),customer_earned_points.created_at,111)       
								BETWEEN CONVERT(CHAR(10),@start_date,111) and 
								CONVERT(CHAR(10),@end_date,111) 
								Group by customer_id)
								,
								--------------------------------------
								net_Points_temp as 
								(select wink_net_canid_earned_points.customer_id,SUM(wink_net_canid_earned_points.total_points) As total_nets_points 
								from wink_net_canid_earned_points      
									where   
									CAST (wink_net_canid_earned_points.created_at AS Date ) BETWEEN CAST (@start_date AS date)  and CAST (@end_date AS date)       
  									GROUP By wink_net_canid_earned_points.customer_id     
					      
									) ,
						 
								------------------------------------- 
						
						
								alltime_total_evoucher_temp as
								(select customer_id, COUNT(*)  AS alltime_total_evoucher 

								,SUM(redeemed_winks) as alltime_Redeemed_Winks  from customer_earned_evouchers  
								where      
								CAST(customer_earned_evouchers.created_at AS DATE) <= @end_date 
								group by customer_id),
			            
								--------------------------------
			          
								alltime_total_expired_evoucher_temp as
								(select customer_id, COUNT(*)  AS alltime_total_expired_evoucher 

								from customer_earned_evouchers  
								where       
								CAST(customer_earned_evouchers.created_at AS DATE) <= @end_date 
								AND CAST (customer_earned_evouchers.expired_date AS  Date) <= CAST (@CURRENT_DATETIME AS Date)   
								and used_status =0
								group by customer_id),
								------------------------------------------
									alltime_Total_Redeemed_eVouchers_temp as
								(Select customer_id,COUNT(*) As 

									alltime_total_Redeemed_evoucher from customer_earned_evouchers 
									where 
									customer_earned_evouchers.used_status =1 
									AND Cast (created_at as date) <= cast(@end_date as date)
									group by customer_id
									) 
									,
								-----------------------------------------------------  
					  
								alltime_customer_earned_points_temp as 
								(Select ISNULL(SUM (customer_earned_points.points),0) as alltime_Total_QR_Points
								,customer_id
								from customer_earned_points
								where  CAST(customer_earned_points.created_at as date) <= CAST(@end_date as date) 
								Group by customer_earned_points.customer_id 
			       				),
			       				-----------------------------------
			       					alltime_Total_Trip_Points_temp as
									(      
					           
									select customer_id,SUM(wink_canid_earned_points.total_points) As alltime_Total_Trip_Points

									from wink_canid_earned_points      
									where  
									CAST (wink_canid_earned_points.created_at AS date) <= CAST (@end_date AS date)       
									GROUP By customer_id      
					      
									),
			
									-----------------------------------------
									all_time_total_net_points_temp as 
									(      
									select wink_net_canid_earned_points.customer_id,SUM(wink_net_canid_earned_points.total_points)  As all_time_nets_points 
									from wink_net_canid_earned_points      
										where  
										CAST (wink_net_canid_earned_points.created_at AS Date ) <= CAST (@end_date AS date)     

									GROUP By wink_net_canid_earned_points.customer_id   
									),
									---------------------------------------    
			       	    
									alltime_Confiscated_Points_temp as 
									(      
					      
									Select customer_id,ISNULL(SUM(points_confiscated_detail.confiscated_points),0)  AS alltime_Confiscated_Points  
									from 
									points_confiscated_detail       
									where
									CAST (points_confiscated_detail.created_at AS date)<=CAST (@end_date AS date)
						 
									GROUP By customer_id      
					      
									),
									---------------------------------------
									alltime_Redeemed_Points_temp as    
									(      
					      
									Select customer_id,ISNULL(SUM(customer_earned_winks.redeemed_points),0) AS alltime_Redeemed_Points  
									from customer_earned_winks       
									where  
									CAST (customer_earned_winks.created_at AS date) <= 
									CAST (@end_date AS date)       


									GROUP By customer_id        
					      
									) ,
						 
									-------------------------------
									alltime_Total_Winks_temp as 
									( Select customer_id,SUM(ISNULL(customer_earned_winks.total_winks,0))AS alltime_Total_Winks 
														
									from customer_earned_winks       
									where 
									( CAST (customer_earned_winks.created_at AS date) <= CAST (@end_date AS date) )      
									GROUP By customer_earned_winks.customer_id   
									),
									----------------------------------
								alltime_Confiscated_Winks_temp as 
										(      
						      
										Select wink_confiscated_detail.customer_id,SUM(ISNULL(wink_confiscated_detail.total_winks,0)) AS alltime_Confiscated_Winks 
										from wink_confiscated_detail       
										where 
										CAST(wink_confiscated_detail.created_at as date) <= CAST(@end_date as date)

										GROUP By customer_id           
						     
										) , 	 
			       	  
			       	  
			       				expired_eVouchers_temp as 
							(
					
							select COUNT(*) AS Expired_Evoucher,customer_id

								from customer_earned_evouchers       
							where   
							customer_earned_evouchers.used_status = 0 
							AND CAST(created_at AS DATE) 
							BETWEEN Cast (@start_date as DATE) AND       
							Cast (@end_date as DATE)
							AND CAST (expired_date AS Date) <= CAST(@CURRENT_DATETIME AS Date)   
			          
							Group By customer_id 
						        
							),
			        
							Total_Winks_temp as
							(Select customer_id,SUM(ISNULL(customer_earned_winks.total_winks,0)) as Total_Winks
 
									from customer_earned_winks       
									where     
									CAST (customer_earned_winks.created_at AS date)  BETWEEN CAST (@start_date AS date)  and CAST (@end_date AS date)       
									GROUP By customer_earned_winks.customer_id    
							),
								----------------------------------------
							total_eVoucher_temp AS 
							(select COUNT(*) AS Total_eVoucher,SUM(redeemed_winks) as Redeemed_Winks ,
							customer_id 
								from customer_earned_evouchers       
								where  
								CAST(customer_earned_evouchers.created_at AS DATE) 
								BETWEEN CAST(@start_date as date) AND Cast(@end_date as date)
								group by customer_id 
								),
								total_winks_confiscated_temp as
							(      
		      
							Select customer_id, SUM(ISNULL(wink_confiscated_detail.total_winks,0)) as total_winks_confiscated 

							from  wink_confiscated_detail where     
								CAST (wink_confiscated_detail.created_at AS date) BETWEEN CAST (@start_date AS date)  and CAST (@end_date AS date)       
								GROUP By wink_confiscated_detail.customer_id
							),
								total_points_confiscated_temp as 
								(      
		      
									Select customer_id,SUM(ISNULL(points_confiscated_detail.confiscated_points,0))  AS total_points_confiscated from 
									points_confiscated_detail where    
									CAST (points_confiscated_detail.created_at AS date) 
									BETWEEN CAST (@start_date AS date)  and CAST(@end_date AS date)       
									GROUP By points_confiscated_detail.customer_id      
								),
                     
			    				--------------------------------------
								customer_cic_points_temp as 
							(Select ISNULL(SUM(cic_table.total_points),0) as Total_CIC_Points,customer_id       
								from cic_table 
								where --customer_id = @customer_id and   
								CONVERT(CHAR (10),cic_table.created_at,111)       
								BETWEEN CONVERT(CHAR(10),@start_date,111) and 
								CONVERT(CHAR(10),@end_date,111) 
								Group by customer_id),
					  
								--------------------------------------
								alltime_cic_Points_temp as
									(      
					           
								Select ISNULL(SUM(cic_table.total_points),0) as alltime_Total_CIC_Points,customer_id
						         
								from cic_table 
								where --customer_id = @customer_id and   
								CONVERT(CHAR (10),cic_table.created_at,111)       
								<= CONVERT(CHAR(10),@end_date,111)  
					  
								Group by customer_id    
					      
									),

							--------------winktag------------------------
							customer_winktag_points_temp as 
							(Select ISNULL(SUM(winktag.points),0) as Total_WINKTAG_Points,customer_id       
							from winktag_customer_earned_points as winktag 
							where --customer_id = @customer_id and   
							CONVERT(CHAR (10),winktag.created_at,111)       
							BETWEEN CONVERT(CHAR(10),@start_date,111) and 
							CONVERT(CHAR(10),@end_date,111) 
							Group by customer_id),

							--------------------------------------
							alltime_winktag_Points_temp as
							(      
		   
							Select ISNULL(SUM(winktag.points),0) as alltime_Total_WINKTag_Points,customer_id         
							from winktag_customer_earned_points as winktag  
							where --customer_id = @customer_id and   
							CONVERT(CHAR (10),winktag.created_at,111)       
							<= CONVERT(CHAR(10),@end_date,111)  	  
							Group by customer_id),
					
							--------------Manual Points Insertion------------------------
							customer_misc_points_temp as 
							(
							Select ISNULL(SUM(misc.points),0) as Total_Misc_Points,customer_id       
							from winners_points as misc 
							where CONVERT(CHAR (10),misc.created_at,111)       
							BETWEEN CONVERT(CHAR(10),@start_date,111) and 
							CONVERT(CHAR(10),@end_date,111) 
							Group by customer_id
							),

								--------------------------------------
							alltime_misc_Points_temp as
							(      					           
							Select ISNULL(SUM(misc.points),0) as alltime_Total_Misc_Points,customer_id         
							from winners_points as misc  
							where CONVERT(CHAR (10),misc.created_at,111)       
							<= CONVERT(CHAR(10),@end_date,111)  
							Group by customer_id
							)
					  
			       
							select c.customer_id, first_name,last_name,email,[status], total_count,ip_address,ip_scanned,wid, [group],
							(ISNULL (Trip_Points,0)+  ISNULL(Total_QR_Scan_Points,0) 
							+  ISNULL (total_nets_points,0) 
					
							+  ISNULL (Total_CIC_Points,0)
							+ ISNULL (Total_WINKTAG_Points,0)
							+ ISNULL (Total_Misc_Points,0)
					
							) as total_points,
								(ISNULL (alltime_total_evoucher,0)-  ISNULL (alltime_total_Redeemed_evoucher,0) - ISNULl (alltime_total_expired_evoucher,0)) as balanced_evouchers,  
								( 
									(ISNULL(alltime_Total_QR_Points,0) 
									+ ISNULL ( alltime_Total_CIC_Points,0)
									+ ISNULL ( alltime_Total_WINKTag_Points,0)
									+ ISNULL ( alltime_Total_Misc_Points,0)
								+ ISNULL (alltime_Total_Trip_Points,0) 
								+ ISNULL ( all_time_nets_points,0))
								- (ISNULL(alltime_Confiscated_Points,0)+ISNULL(alltime_Redeemed_Points,0)))as balanced_points,	    			    
					    
								(ISNULL (alltime_Total_Winks,0)- ISNULL (alltime_Redeemed_Winks ,0 )-ISNULL(alltime_Confiscated_Winks,0)) as balanced_winks,
								ISNULl (Expired_Evoucher,0) as Expired_Evoucher,
								ISNULL (Total_eVoucher,0) as Total_eVoucher , 
								ISNULL (No_Of_Scan,0) as No_Of_Scan,
								ISNULL(Total_Winks,0) as Total_Winks,
								ISNULL (total_winks_confiscated,0) as total_winks_confiscated,
								ISNULL (total_points_confiscated,0) as total_points_confiscated,
								ISNULL (Redeemed_winks,0) as Redeemed_winks
					   
					 			  
					 
								from customer_temp as c left join 
								customer_earned_points_temp as points on
								c.customer_id = points.customer_id
								left join Trip_Points_temp as d
								on d.customer_id = c.customer_id
								left join net_Points_temp as e
								on e.customer_id = c.customer_id
								left join Total_Winks_temp as f
								on f.customer_id = c.customer_id
								left join alltime_total_evoucher_temp as g
								on g.customer_id = c.customer_id
								left join alltime_Total_Redeemed_eVouchers_temp as h
								on h.customer_id = c.customer_id
								left join alltime_total_expired_evoucher_temp as i
								on i.customer_id = c.customer_id
								left join alltime_customer_earned_points_temp as j
								on c.customer_id = j.customer_id
								left join alltime_Total_Trip_Points_temp as k
								on k.customer_id = c.customer_id
								left join all_time_total_net_points_temp as l
								on l.customer_id = c.customer_id
								left join alltime_Confiscated_Points_temp as o
								on o.customer_id = c.customer_id
								left join alltime_Redeemed_Points_temp as p
								on p.customer_id = c.customer_id
								left join alltime_Total_Winks_temp as q
								on q.customer_id = c.customer_id
								left join alltime_Confiscated_Winks_temp as r
								on r.customer_id = c.customer_id
								left join expired_eVouchers_temp as s
								on s.customer_id = c.customer_id
								left join total_eVoucher_temp as t
								on t.customer_id = c.customer_id
								left join total_winks_confiscated_temp as u
								on c.customer_id = u.customer_id
								left join total_points_confiscated_temp as v
								on c.customer_id = v.customer_id
								left join customer_cic_points_temp as w
								on c.customer_id = w.customer_id
								left join alltime_cic_Points_temp as x
								on c.customer_id = x.customer_id
								left join customer_winktag_points_temp as y
							on c.customer_id = y.customer_id
							left join alltime_winktag_Points_temp as z
							on c.customer_id = z.customer_id
							left join customer_misc_points_temp as a
								on c.customer_id = a.customer_id
								left join alltime_misc_Points_temp as b
								on c.customer_id = b.customer_id
										 
								group by c.customer_id
								,first_name,last_name,email, status,ip_address,ip_scanned,wid, [group],     
								Total_QR_Scan_Points, Trip_Points,total_nets_points,
								alltime_total_evoucher, alltime_total_Redeemed_evoucher,alltime_total_expired_evoucher,
								alltime_Total_QR_Points, all_time_nets_points,alltime_Total_Trip_Points,
								alltime_Redeemed_Points,alltime_Confiscated_Points,
								alltime_Total_Winks,alltime_Redeemed_Winks,alltime_Confiscated_Winks,
								Expired_Evoucher,Total_eVoucher,      
								No_Of_Scan,     
								Total_Winks,   
								total_count,
								total_winks_confiscated,
								total_points_confiscated,
								Redeemed_winks,
								alltime_Total_CIC_Points,
								Total_CIC_Points,
								alltime_Total_WINKTag_Points,
								Total_WINKTAG_Points,
								alltime_Total_Misc_Points,
								Total_Misc_Points
					  
					  
								order by No_Of_Scan desc
			END
			------------------------------ Ip scanned is not null -----------------------
			ELSE IF (@ip_scanned is not null and @ip_scanned !='')		  
			BEGIN 
				;WITH customer_temp AS
				(
                    
					SELECT customer.customer_id,customer.first_name,customer.last_name,ip_address,ip_scanned,
					ROW_NUMBER() OVER(ORDER BY customer.customer_id DESC) as intRow, 
					COUNT(customer.customer_id) OVER() AS total_count ,    
					customer.email , temp.locked_desc as [status],customer.WID, cusGroup.group_name as [group] from customer 
					join customer_group as cusGroup
					on customer.group_id = cusGroup.group_id
					and (@group_id is null or cusGroup.group_id = @group_id
					or cusGroup.group_id = @imob_group_id1 or cusGroup.group_id = @imob_group_id2 
					or cusGroup.group_id = @imob_group_id3 or cusGroup.group_id = @imob_group_id4
					or cusGroup.group_id = @imob_group_id5 or cusGroup.group_id = @imob_group_id6)
					inner join #Customer_AutoLog_Table as temp on customer.customer_id = temp.customer_id
			      
					where customer.ip_scanned like '%'+ @ip_scanned+'%'
					AND (@wid is null or customer.WID like '%'+ @wid+'%')
					AND (@customer_name is null  or Lower(customer.first_name +' '+ customer.last_name) LIKE Lower( '%'+@customer_name +'%')) 
					AND (@customer_email is null  or Lower(customer.email) LIKE Lower('%'+LTRIM(RTRIM(@customer_email))+'%'))   
					AND (@status is null  or Lower(customer.[status]) LIKE Lower(@status+'%'))
				),
							------------------------------
							
								Trip_Points_temp As
							(
				           
								select customer_id,SUM(wink_canid_earned_points.total_points) As trip_points 
								from wink_canid_earned_points      


								where   
					 
								CAST (wink_canid_earned_points.created_at AS Date )       
								BETWEEN CAST (@start_date AS date)  and CAST (@end_date AS date)   
								GROUP By customer_id            
				         
								)      
								, 
								-----------------------------------
								
								customer_earned_points_temp as 
							(Select ISNULL(SUM
							(customer_earned_points.points),0) as Total_QR_Scan_Points,customer_id,
								COUNT(*) as No_Of_Scan
								from customer_earned_points 
								where  
								CONVERT(CHAR (10),customer_earned_points.created_at,111)       
								BETWEEN CONVERT(CHAR(10),@start_date,111) and 
								CONVERT(CHAR(10),@end_date,111) 
								Group by customer_id)
								,
								--------------------------------------
								net_Points_temp as 
								(select wink_net_canid_earned_points.customer_id,SUM(wink_net_canid_earned_points.total_points) As total_nets_points 
								from wink_net_canid_earned_points      
									where 
									CAST (wink_net_canid_earned_points.created_at AS Date ) BETWEEN CAST (@start_date AS date)  and CAST (@end_date AS date)       
  									GROUP By wink_net_canid_earned_points.customer_id     
					      
									) ,
						 
								------------------------------------- 
						
						
								alltime_total_evoucher_temp as
								(select customer_id, COUNT(*)  AS alltime_total_evoucher 

								,SUM(redeemed_winks) as alltime_Redeemed_Winks  from customer_earned_evouchers  
								where        
								CAST(customer_earned_evouchers.created_at AS DATE) <= @end_date 
								group by customer_id),
			            
								--------------------------------
			          
								alltime_total_expired_evoucher_temp as
								(select customer_id, COUNT(*)  AS alltime_total_expired_evoucher 

								from customer_earned_evouchers  
								where    
								CAST(customer_earned_evouchers.created_at AS DATE) <= @end_date 
								AND CAST (customer_earned_evouchers.expired_date AS  Date) <= CAST (@CURRENT_DATETIME AS Date)   
								and used_status =0
								group by customer_id),
								------------------------------------------
									alltime_Total_Redeemed_eVouchers_temp as
								(Select customer_id,COUNT(*) As 

									alltime_total_Redeemed_evoucher from customer_earned_evouchers 
									where 
									customer_earned_evouchers.used_status =1 
									AND Cast (created_at as date) <= cast(@end_date as date)
									group by customer_id
									) 
									,
								-----------------------------------------------------  
					  
								alltime_customer_earned_points_temp as 
								(Select ISNULL(SUM (customer_earned_points.points),0) as alltime_Total_QR_Points
								,customer_id
								from customer_earned_points
								where  CAST(customer_earned_points.created_at as date) <= CAST(@end_date as date) 
								Group by customer_earned_points.customer_id 
			       				),
			       				-----------------------------------
			       					alltime_Total_Trip_Points_temp as
									(      
					           
									select customer_id,SUM(wink_canid_earned_points.total_points) As alltime_Total_Trip_Points

									from wink_canid_earned_points      
									where  
									CAST (wink_canid_earned_points.created_at AS date) <= CAST (@end_date AS date)       
									GROUP By customer_id      
					      
									),
			
									-----------------------------------------
									all_time_total_net_points_temp as 
									(      
									select wink_net_canid_earned_points.customer_id,SUM(wink_net_canid_earned_points.total_points)  As all_time_nets_points 
									from wink_net_canid_earned_points      
										where  
										CAST (wink_net_canid_earned_points.created_at AS Date ) <= CAST (@end_date AS date)     

									GROUP By wink_net_canid_earned_points.customer_id   
									),
									---------------------------------------    
			       	    
									alltime_Confiscated_Points_temp as 
									(      
					      
									Select customer_id,ISNULL(SUM(points_confiscated_detail.confiscated_points),0)  AS alltime_Confiscated_Points  
									from 
									points_confiscated_detail       
									where CAST (points_confiscated_detail.created_at AS date)<=CAST (@end_date AS date)
						 
									GROUP By customer_id      
					      
									),
									---------------------------------------
									alltime_Redeemed_Points_temp as    
									(      
					      
									Select customer_id,ISNULL(SUM(customer_earned_winks.redeemed_points),0) AS alltime_Redeemed_Points  
									from customer_earned_winks       
									where    
									CAST (customer_earned_winks.created_at AS date) <= 
									CAST (@end_date AS date)       


									GROUP By customer_id        
					      
									) ,
						 
									-------------------------------
									alltime_Total_Winks_temp as 
									( Select customer_id,SUM(ISNULL(customer_earned_winks.total_winks,0))AS alltime_Total_Winks 
														
									from customer_earned_winks       
									where 
									( CAST (customer_earned_winks.created_at AS date) <= CAST (@end_date AS date) )      
									GROUP By customer_earned_winks.customer_id   
									),
									----------------------------------
								alltime_Confiscated_Winks_temp as 
										(      
						      
										Select wink_confiscated_detail.customer_id,SUM(ISNULL(wink_confiscated_detail.total_winks,0)) AS alltime_Confiscated_Winks 
										from wink_confiscated_detail       
										where 
										CAST(wink_confiscated_detail.created_at as date) <= CAST(@end_date as date)

										GROUP By customer_id           
						     
										) , 	 
			       	  
			       	  
			       				expired_eVouchers_temp as 
							(
					
							select COUNT(*) AS Expired_Evoucher,customer_id

								from customer_earned_evouchers       
							where   
							customer_earned_evouchers.used_status = 0 
							AND CAST(created_at AS DATE) 
							BETWEEN Cast (@start_date as DATE) AND       
							Cast (@end_date as DATE)
							AND CAST (expired_date AS Date) <= CAST(@CURRENT_DATETIME AS Date)   
			          
							Group By customer_id 
						        
							),
			        
							Total_Winks_temp as
							(Select customer_id,SUM(ISNULL(customer_earned_winks.total_winks,0)) as Total_Winks
 
									from customer_earned_winks       
									where    
									CAST (customer_earned_winks.created_at AS date)  BETWEEN CAST (@start_date AS date)  and CAST (@end_date AS date)       
									GROUP By customer_earned_winks.customer_id    
							),
								----------------------------------------
							total_eVoucher_temp AS 
							(select COUNT(*) AS Total_eVoucher,SUM(redeemed_winks) as Redeemed_Winks ,
							customer_id 
								from customer_earned_evouchers       
								where 
								CAST(customer_earned_evouchers.created_at AS DATE) 
								BETWEEN CAST(@start_date as date) AND Cast(@end_date as date)
								group by customer_id 
								),
								total_winks_confiscated_temp as
							(      
		      
							Select customer_id, SUM(ISNULL(wink_confiscated_detail.total_winks,0)) as total_winks_confiscated 

							from  wink_confiscated_detail where 
								CAST (wink_confiscated_detail.created_at AS date) BETWEEN CAST (@start_date AS date)  and CAST (@end_date AS date)       
								GROUP By wink_confiscated_detail.customer_id
							),
								total_points_confiscated_temp as 
								(      
		      
									Select customer_id,SUM(ISNULL(points_confiscated_detail.confiscated_points,0))  AS total_points_confiscated from 
									points_confiscated_detail where CAST (points_confiscated_detail.created_at AS date) 
									BETWEEN CAST (@start_date AS date)  and CAST(@end_date AS date)       
									GROUP By points_confiscated_detail.customer_id      
								),
			       
								--------------------------------------
								customer_cic_points_temp as 
							(Select ISNULL(SUM(cic_table.total_points),0) as Total_CIC_Points,customer_id       
								from cic_table 
								where --customer_id = @customer_id and   
								CONVERT(CHAR (10),cic_table.created_at,111)       
								BETWEEN CONVERT(CHAR(10),@start_date,111) and 
								CONVERT(CHAR(10),@end_date,111) 
								Group by customer_id),
					  
								--------------------------------------
								alltime_cic_Points_temp as
									(      
					           
								Select ISNULL(SUM(cic_table.total_points),0) as alltime_Total_CIC_Points,customer_id
						         
								from cic_table 
								where --customer_id = @customer_id and   
								CONVERT(CHAR (10),cic_table.created_at,111)       
								<= CONVERT(CHAR(10),@end_date,111)  
					  
								Group by customer_id    
					      
									),

							--------------winktag------------------------
							customer_winktag_points_temp as 
							(Select ISNULL(SUM(winktag.points),0) as Total_WINKTAG_Points,customer_id       
							from winktag_customer_earned_points as winktag 
							where --customer_id = @customer_id and   
							CONVERT(CHAR (10),winktag.created_at,111)       
							BETWEEN CONVERT(CHAR(10),@start_date,111) and 
							CONVERT(CHAR(10),@end_date,111) 
							Group by customer_id),

							--------------------------------------
							alltime_winktag_Points_temp as
							(      
		   
							Select ISNULL(SUM(winktag.points),0) as alltime_Total_WINKTag_Points,customer_id         
							from winktag_customer_earned_points as winktag  
							where --customer_id = @customer_id and   
							CONVERT(CHAR (10),winktag.created_at,111)       
							<= CONVERT(CHAR(10),@end_date,111)  	  
							Group by customer_id),
					
							--------------Manual Points Insertion------------------------
							customer_misc_points_temp as 
							(
							Select ISNULL(SUM(misc.points),0) as Total_Misc_Points,customer_id       
							from winners_points as misc 
							where CONVERT(CHAR (10),misc.created_at,111)       
							BETWEEN CONVERT(CHAR(10),@start_date,111) and 
							CONVERT(CHAR(10),@end_date,111) 
							Group by customer_id
							),

								--------------------------------------
							alltime_misc_Points_temp as
							(      					           
							Select ISNULL(SUM(misc.points),0) as alltime_Total_Misc_Points,customer_id         
							from winners_points as misc  
							where CONVERT(CHAR (10),misc.created_at,111)       
							<= CONVERT(CHAR(10),@end_date,111)  
							Group by customer_id
							)
					  
			       
							select c.customer_id, first_name,last_name,email,[status], total_count,ip_address,ip_scanned,wid, [group],
							(ISNULL (Trip_Points,0)+  ISNULL(Total_QR_Scan_Points,0) 
							+  ISNULL (total_nets_points,0) 
					
							+  ISNULL (Total_CIC_Points,0)
							+ ISNULL (Total_WINKTAG_Points,0)
							+ ISNULL (Total_Misc_Points,0)
					
							) as total_points,
								(ISNULL (alltime_total_evoucher,0)-  ISNULL (alltime_total_Redeemed_evoucher,0) - ISNULl (alltime_total_expired_evoucher,0)) as balanced_evouchers,  
								( 
									(ISNULL(alltime_Total_QR_Points,0) 
									+ ISNULL ( alltime_Total_CIC_Points,0)
									+ ISNULL ( alltime_Total_WINKTag_Points,0)
									+ ISNULL ( alltime_Total_Misc_Points,0)
								+ ISNULL (alltime_Total_Trip_Points,0) 
								+ ISNULL ( all_time_nets_points,0))
								- (ISNULL(alltime_Confiscated_Points,0)+ISNULL(alltime_Redeemed_Points,0)))as balanced_points,	    			    
					    
								(ISNULL (alltime_Total_Winks,0)- ISNULL (alltime_Redeemed_Winks ,0 )-ISNULL(alltime_Confiscated_Winks,0)) as balanced_winks,
								ISNULl (Expired_Evoucher,0) as Expired_Evoucher,
								ISNULL (Total_eVoucher,0) as Total_eVoucher , 
								ISNULL (No_Of_Scan,0) as No_Of_Scan,
								ISNULL(Total_Winks,0) as Total_Winks,
								ISNULL (total_winks_confiscated,0) as total_winks_confiscated,
								ISNULL (total_points_confiscated,0) as total_points_confiscated,
								ISNULL (Redeemed_winks,0) as Redeemed_winks
					   
					 			  
					 
								from customer_temp as c left join 
								customer_earned_points_temp as points on
								c.customer_id = points.customer_id
								left join Trip_Points_temp as d
								on d.customer_id = c.customer_id
								left join net_Points_temp as e
								on e.customer_id = c.customer_id
								left join Total_Winks_temp as f
								on f.customer_id = c.customer_id
								left join alltime_total_evoucher_temp as g
								on g.customer_id = c.customer_id
								left join alltime_Total_Redeemed_eVouchers_temp as h
								on h.customer_id = c.customer_id
								left join alltime_total_expired_evoucher_temp as i
								on i.customer_id = c.customer_id
								left join alltime_customer_earned_points_temp as j
								on c.customer_id = j.customer_id
								left join alltime_Total_Trip_Points_temp as k
								on k.customer_id = c.customer_id
								left join all_time_total_net_points_temp as l
								on l.customer_id = c.customer_id
								left join alltime_Confiscated_Points_temp as o
								on o.customer_id = c.customer_id
								left join alltime_Redeemed_Points_temp as p
								on p.customer_id = c.customer_id
								left join alltime_Total_Winks_temp as q
								on q.customer_id = c.customer_id
								left join alltime_Confiscated_Winks_temp as r
								on r.customer_id = c.customer_id
								left join expired_eVouchers_temp as s
								on s.customer_id = c.customer_id
								left join total_eVoucher_temp as t
								on t.customer_id = c.customer_id
								left join total_winks_confiscated_temp as u
								on c.customer_id = u.customer_id
								left join total_points_confiscated_temp as v
								on c.customer_id = v.customer_id
								left join customer_cic_points_temp as w
								on c.customer_id = w.customer_id
								left join alltime_cic_Points_temp as x
								on c.customer_id = x.customer_id
								left join customer_winktag_points_temp as y
							on c.customer_id = y.customer_id
							left join alltime_winktag_Points_temp as z
							on c.customer_id = z.customer_id
							left join customer_misc_points_temp as a
								on c.customer_id = a.customer_id
								left join alltime_misc_Points_temp as b
								on c.customer_id = b.customer_id
										 
								group by c.customer_id
								,first_name,last_name,email, status,ip_address,ip_scanned,wid, [group],     
								Total_QR_Scan_Points, Trip_Points,total_nets_points,
								alltime_total_evoucher, alltime_total_Redeemed_evoucher,alltime_total_expired_evoucher,
								alltime_Total_QR_Points, all_time_nets_points,alltime_Total_Trip_Points,
								alltime_Redeemed_Points,alltime_Confiscated_Points,
								alltime_Total_Winks,alltime_Redeemed_Winks,alltime_Confiscated_Winks,
								Expired_Evoucher,Total_eVoucher,      
								No_Of_Scan,     
								Total_Winks,   
								total_count,
								total_winks_confiscated,
								total_points_confiscated,
								Redeemed_winks,
								alltime_Total_CIC_Points,
								Total_CIC_Points,
								alltime_Total_WINKTag_Points,
								Total_WINKTAG_Points,
								alltime_Total_Misc_Points,
								Total_Misc_Points
					  
					  
								order by No_Of_Scan desc
			END
			---------------------------NO IP Filter -------------------------------------------- 
			ELSE   
			BEGIN 	
				;WITH customer_temp AS
				(
					SELECT customer.customer_id,customer.first_name,customer.last_name,ip_address,ip_scanned,
					ROW_NUMBER() OVER(ORDER BY customer.customer_id DESC) as intRow, 
					COUNT(customer.customer_id) OVER() AS total_count ,    
					customer.email ,temp.locked_desc as [status],customer.WID, cusGroup.group_name as [group] from customer 

					inner join #Customer_AutoLog_Table as temp on customer.customer_id = temp.customer_id
					join customer_group as cusGroup
					on customer.group_id = cusGroup.group_id
					and (@group_id is null or cusGroup.group_id = @group_id
					or cusGroup.group_id = @imob_group_id1 or cusGroup.group_id = @imob_group_id2 
					or cusGroup.group_id = @imob_group_id3 or cusGroup.group_id = @imob_group_id4
					or cusGroup.group_id = @imob_group_id5 or cusGroup.group_id = @imob_group_id6)
					where 
			         
					customer.customer_id in (select #Customer_AutoLog_Table.customer_id from #Customer_AutoLog_Table)
			        AND (@wid is null or customer.WID like '%'+ @wid+'%')
					AND (@customer_name is null  or Lower(customer.first_name +' '+ customer.last_name) LIKE Lower( '%'+@customer_name +'%'))      
					AND (@customer_email is null  or Lower(customer.email) LIKE Lower('%'+LTRIM(RTRIM(@customer_email))+'%'))   
					AND (@status is null  or Lower(customer.[status]) LIKE Lower(@status+'%'))
					),
				------------------------------
							
					Trip_Points_temp As
				(
				           
					select customer_id,SUM(wink_canid_earned_points.total_points) As trip_points 
					from wink_canid_earned_points      


					where  
					 
					CAST (wink_canid_earned_points.created_at AS Date )       
					BETWEEN CAST (@start_date AS date)  and CAST (@end_date AS date)   
					GROUP By customer_id            
				         
					)      
					, 
					-----------------------------------
								
					customer_earned_points_temp as 
				(Select ISNULL(SUM
				(customer_earned_points.points),0) as Total_QR_Scan_Points,customer_id,
					COUNT(*) as No_Of_Scan
					from customer_earned_points 
					where 
					CONVERT(CHAR (10),customer_earned_points.created_at,111)       
					BETWEEN CONVERT(CHAR(10),@start_date,111) and 
					CONVERT(CHAR(10),@end_date,111) 
					Group by customer_id)
					,
					--------------------------------------
					net_Points_temp as 
					(select wink_net_canid_earned_points.customer_id,SUM(wink_net_canid_earned_points.total_points) As total_nets_points 
					from wink_net_canid_earned_points      
						where  
						CAST (wink_net_canid_earned_points.created_at AS Date ) BETWEEN CAST (@start_date AS date)  and CAST (@end_date AS date)       
  						GROUP By wink_net_canid_earned_points.customer_id     
					      
						) ,
						 
					------------------------------------- 
						
						
					alltime_total_evoucher_temp as
					(select customer_id, COUNT(*)  AS alltime_total_evoucher 

					,SUM(redeemed_winks) as alltime_Redeemed_Winks  from customer_earned_evouchers  
					where    
					CAST(customer_earned_evouchers.created_at AS DATE) <= @end_date 
					group by customer_id),
			            
					--------------------------------
			          
					alltime_total_expired_evoucher_temp as
					(select customer_id, COUNT(*)  AS alltime_total_expired_evoucher 

					from customer_earned_evouchers  
					where  
					CAST(customer_earned_evouchers.created_at AS DATE) <= @end_date 
					AND CAST (customer_earned_evouchers.expired_date AS  Date) <= CAST (@CURRENT_DATETIME AS Date)   
					and used_status =0
					group by customer_id),
					------------------------------------------
						alltime_Total_Redeemed_eVouchers_temp as
					(Select customer_id,COUNT(*) As 

						alltime_total_Redeemed_evoucher from customer_earned_evouchers 
						where 
						customer_earned_evouchers.used_status =1 
						AND Cast (created_at as date) <= cast(@end_date as date)
						group by customer_id
						) 
						,
					-----------------------------------------------------  
					  
					alltime_customer_earned_points_temp as 
					(Select ISNULL(SUM (customer_earned_points.points),0) as alltime_Total_QR_Points
					,customer_id
					from customer_earned_points
					where  CAST(customer_earned_points.created_at as date) <= CAST(@end_date as date) 
					Group by customer_earned_points.customer_id 
			       	),
			       	-----------------------------------
			       		alltime_Total_Trip_Points_temp as
						(      
					           
						select customer_id,SUM(wink_canid_earned_points.total_points) As alltime_Total_Trip_Points

						from wink_canid_earned_points      
						where 
						CAST (wink_canid_earned_points.created_at AS date) <= CAST (@end_date AS date)       
						GROUP By customer_id      
					      
						),
			
						-----------------------------------------
						all_time_total_net_points_temp as 
						(      
						select wink_net_canid_earned_points.customer_id,SUM(wink_net_canid_earned_points.total_points)  As all_time_nets_points 
						from wink_net_canid_earned_points      
							where 
							CAST (wink_net_canid_earned_points.created_at AS Date ) <= CAST (@end_date AS date)     

						GROUP By wink_net_canid_earned_points.customer_id   
						),
						---------------------------------------    
			       	    
						alltime_Confiscated_Points_temp as 
						(      
					      
						Select customer_id,ISNULL(SUM(points_confiscated_detail.confiscated_points),0)  AS alltime_Confiscated_Points  
						from 
						points_confiscated_detail       
						where CAST (points_confiscated_detail.created_at AS date)<=CAST (@end_date AS date)
						 
						GROUP By customer_id      
					      
						),
						---------------------------------------
						alltime_Redeemed_Points_temp as    
						(      
					      
						Select customer_id,ISNULL(SUM(customer_earned_winks.redeemed_points),0) AS alltime_Redeemed_Points  
						from customer_earned_winks       
						where 
						CAST (customer_earned_winks.created_at AS date) <= 
						CAST (@end_date AS date)       


						GROUP By customer_id        
					      
						) ,
						 
						-------------------------------
						alltime_Total_Winks_temp as 
						( Select customer_id,SUM(ISNULL(customer_earned_winks.total_winks,0))AS alltime_Total_Winks 
														
						from customer_earned_winks       
						where 
						( CAST (customer_earned_winks.created_at AS date) <= CAST (@end_date AS date) )      
						GROUP By customer_earned_winks.customer_id   
						),
						----------------------------------
					alltime_Confiscated_Winks_temp as 
							(      
						      
							Select wink_confiscated_detail.customer_id,SUM(ISNULL(wink_confiscated_detail.total_winks,0)) AS alltime_Confiscated_Winks 
							from wink_confiscated_detail       
							where 
							CAST(wink_confiscated_detail.created_at as date) <= CAST(@end_date as date)

							GROUP By customer_id           
						     
							) , 	 
			       	  
			       	  
			       	expired_eVouchers_temp as 
				(
					
				select COUNT(*) AS Expired_Evoucher,customer_id

					from customer_earned_evouchers       
				where 
				customer_earned_evouchers.used_status = 0 
				AND CAST(created_at AS DATE) 
				BETWEEN Cast (@start_date as DATE) AND       
				Cast (@end_date as DATE)
				AND CAST (expired_date AS Date) <= CAST(@CURRENT_DATETIME AS Date)   
			          
				Group By customer_id 
						        
				),
			        
				Total_Winks_temp as
				(Select customer_id,SUM(ISNULL(customer_earned_winks.total_winks,0)) as Total_Winks
 
						from customer_earned_winks       
						where   
						CAST (customer_earned_winks.created_at AS date)  BETWEEN CAST (@start_date AS date)  and CAST (@end_date AS date)       
						GROUP By customer_earned_winks.customer_id    
				),
					----------------------------------------
				total_eVoucher_temp AS 
				(select COUNT(*) AS Total_eVoucher,SUM(redeemed_winks) as Redeemed_Winks ,
				customer_id 
					from customer_earned_evouchers       
					where  
					CAST(customer_earned_evouchers.created_at AS DATE) 
					BETWEEN CAST(@start_date as date) AND Cast(@end_date as date)
					group by customer_id 
					),
					total_winks_confiscated_temp as
				(      
		      
				Select customer_id, SUM(ISNULL(wink_confiscated_detail.total_winks,0)) as total_winks_confiscated 

				from  wink_confiscated_detail where   
					CAST (wink_confiscated_detail.created_at AS date) BETWEEN CAST (@start_date AS date)  and CAST (@end_date AS date)       
					GROUP By wink_confiscated_detail.customer_id
				),
					total_points_confiscated_temp as 
					(      
		      
						Select customer_id,SUM(ISNULL(points_confiscated_detail.confiscated_points,0))  AS total_points_confiscated from 
						points_confiscated_detail where   
						CAST (points_confiscated_detail.created_at AS date) 
						BETWEEN CAST (@start_date AS date)  and CAST(@end_date AS date)       
						GROUP By points_confiscated_detail.customer_id      
					),
			      	--------------------------------------
					customer_cic_points_temp as 
				(Select ISNULL(SUM(cic_table.total_points),0) as Total_CIC_Points,customer_id       
					from cic_table 
					where customer_id = @customer_id and   
					CONVERT(CHAR (10),cic_table.created_at,111)       
					BETWEEN CONVERT(CHAR(10),@start_date,111) and 
					CONVERT(CHAR(10),@end_date,111) 
					Group by customer_id),
					  
					--------------------------------------
					alltime_cic_Points_temp as
						(      
					           
					Select ISNULL(SUM(cic_table.total_points),0) as alltime_Total_CIC_Points,customer_id
						         
					from cic_table 
					where customer_id = @customer_id and   
					CONVERT(CHAR (10),cic_table.created_at,111)       
					<= CONVERT(CHAR(10),@end_date,111)  
					  
					Group by customer_id    
					      
						),

				--------------winktag------------------------
				customer_winktag_points_temp as 
				(Select ISNULL(SUM(winktag.points),0) as Total_WINKTAG_Points,customer_id       
				from winktag_customer_earned_points as winktag 
				where customer_id = @customer_id and   
				CONVERT(CHAR (10),winktag.created_at,111)       
				BETWEEN CONVERT(CHAR(10),@start_date,111) and 
				CONVERT(CHAR(10),@end_date,111) 
				Group by customer_id),

				--------------------------------------
				alltime_winktag_Points_temp as
				(      
		   
				Select ISNULL(SUM(winktag.points),0) as alltime_Total_WINKTag_Points,customer_id         
				from winktag_customer_earned_points as winktag  
				where customer_id = @customer_id and   
				CONVERT(CHAR (10),winktag.created_at,111)       
				<= CONVERT(CHAR(10),@end_date,111)  	  
				Group by customer_id),
					
				--------------Manual Points Insertion------------------------
				customer_misc_points_temp as 
				(
				Select ISNULL(SUM(misc.points),0) as Total_Misc_Points,customer_id       
				from winners_points as misc 
				where customer_id = @customer_id and 
				CONVERT(CHAR (10),misc.created_at,111)       
				BETWEEN CONVERT(CHAR(10),@start_date,111) and 
				CONVERT(CHAR(10),@end_date,111) 
				Group by customer_id
				),

					--------------------------------------
				alltime_misc_Points_temp as
				(      					           
				Select ISNULL(SUM(misc.points),0) as alltime_Total_Misc_Points,customer_id         
				from winners_points as misc  
				where customer_id = @customer_id and 
				CONVERT(CHAR (10),misc.created_at,111)       
				<= CONVERT(CHAR(10),@end_date,111)  
				Group by customer_id
				)
					  
			       
				select c.customer_id, first_name,last_name,email,status, total_count,ip_address,ip_scanned,wid, [group],
				(ISNULL (Trip_Points,0)+  ISNULL(Total_QR_Scan_Points,0) 
				+  ISNULL (total_nets_points,0) 
					
				+  ISNULL (Total_CIC_Points,0)
				+ ISNULL (Total_WINKTAG_Points,0)
				+ ISNULL (Total_Misc_Points,0)
					
				) as total_points,
					(ISNULL (alltime_total_evoucher,0)-  ISNULL (alltime_total_Redeemed_evoucher,0) - ISNULl (alltime_total_expired_evoucher,0)) as balanced_evouchers,  
					( 
						(ISNULL(alltime_Total_QR_Points,0) 
						+ ISNULL ( alltime_Total_CIC_Points,0)
						+ ISNULL ( alltime_Total_WINKTag_Points,0)
						+ ISNULL ( alltime_Total_Misc_Points,0)
					+ ISNULL (alltime_Total_Trip_Points,0) 
					+ ISNULL ( all_time_nets_points,0))
					- (ISNULL(alltime_Confiscated_Points,0)+ISNULL(alltime_Redeemed_Points,0)))as balanced_points,	    			    
					    
					(ISNULL (alltime_Total_Winks,0)- ISNULL (alltime_Redeemed_Winks ,0 )-ISNULL(alltime_Confiscated_Winks,0)) as balanced_winks,
					ISNULl (Expired_Evoucher,0) as Expired_Evoucher,
					ISNULL (Total_eVoucher,0) as Total_eVoucher , 
					ISNULL (No_Of_Scan,0) as No_Of_Scan,
					ISNULL(Total_Winks,0) as Total_Winks,
					ISNULL (total_winks_confiscated,0) as total_winks_confiscated,
					ISNULL (total_points_confiscated,0) as total_points_confiscated,
					ISNULL (Redeemed_winks,0) as Redeemed_winks
					   
					 			  
					 
					from customer_temp as c left join 
					customer_earned_points_temp as points on
					c.customer_id = points.customer_id
					left join Trip_Points_temp as d
					on d.customer_id = c.customer_id
					left join net_Points_temp as e
					on e.customer_id = c.customer_id
					left join Total_Winks_temp as f
					on f.customer_id = c.customer_id
					left join alltime_total_evoucher_temp as g
					on g.customer_id = c.customer_id
					left join alltime_Total_Redeemed_eVouchers_temp as h
					on h.customer_id = c.customer_id
					left join alltime_total_expired_evoucher_temp as i
					on i.customer_id = c.customer_id
					left join alltime_customer_earned_points_temp as j
					on c.customer_id = j.customer_id
					left join alltime_Total_Trip_Points_temp as k
					on k.customer_id = c.customer_id
					left join all_time_total_net_points_temp as l
					on l.customer_id = c.customer_id
					left join alltime_Confiscated_Points_temp as o
					on o.customer_id = c.customer_id
					left join alltime_Redeemed_Points_temp as p
					on p.customer_id = c.customer_id
					left join alltime_Total_Winks_temp as q
					on q.customer_id = c.customer_id
					left join alltime_Confiscated_Winks_temp as r
					on r.customer_id = c.customer_id
					left join expired_eVouchers_temp as s
					on s.customer_id = c.customer_id
					left join total_eVoucher_temp as t
					on t.customer_id = c.customer_id
					left join total_winks_confiscated_temp as u
					on c.customer_id = u.customer_id
					left join total_points_confiscated_temp as v
					on c.customer_id = v.customer_id
					left join customer_cic_points_temp as w
					on c.customer_id = w.customer_id
					left join alltime_cic_Points_temp as x
					on c.customer_id = x.customer_id
					left join customer_winktag_points_temp as y
				on c.customer_id = y.customer_id
				left join alltime_winktag_Points_temp as z
				on c.customer_id = z.customer_id
				left join customer_misc_points_temp as a
					on c.customer_id = a.customer_id
					left join alltime_misc_Points_temp as b
					on c.customer_id = b.customer_id
										 
					group by c.customer_id
					,first_name,last_name,email, status,ip_address,ip_scanned, wid, [group],    
					Total_QR_Scan_Points, Trip_Points,total_nets_points,
					alltime_total_evoucher, alltime_total_Redeemed_evoucher,alltime_total_expired_evoucher,
					alltime_Total_QR_Points, all_time_nets_points,alltime_Total_Trip_Points,
					alltime_Redeemed_Points,alltime_Confiscated_Points,
					alltime_Total_Winks,alltime_Redeemed_Winks,alltime_Confiscated_Winks,
					Expired_Evoucher,Total_eVoucher,      
					No_Of_Scan,     
					Total_Winks,   
					total_count,
					total_winks_confiscated,
					total_points_confiscated,
					Redeemed_winks,
					alltime_Total_CIC_Points,
					Total_CIC_Points,
					alltime_Total_WINKTag_Points,
					Total_WINKTAG_Points,
					alltime_Total_Misc_Points,
					Total_Misc_Points
					order by No_Of_Scan desc
			END
		END
	END
END
