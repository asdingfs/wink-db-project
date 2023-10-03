
Create PROCEDURE [dbo].[Get_Customer_Report_With_Paging2]      
 (@start_date datetime,      
  @end_date datetime,      
  @customer_name varchar(150),      
  @customer_email varchar(150),
  @ip_address varchar(50),
  @status varchar(10),
 
  @customer_id INT,
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
SET @auto_status =''
IF(@status='auto')
BEGIN
SET @status ='disable'
SET @auto_status ='1'
END
ELSE IF(@status='login')
BEGIN
Print('Login')
SET @status ='disable'
SET @auto_status ='2'
END  
 
-- Without Date Time Filter      
 IF OBJECT_ID('tempdb..#Customer_Report_Table') IS NOT NULL DROP TABLE #Customer_Report_Table      
      
 CREATE TABLE #Customer_Report_Table      
 (      
 customer_id int,      
  first_name varchar(200),      
  last_name varchar(200),      
  email varchar(100),
  status varchar(10),      
  Total_QR_Scan_Points int,      
  Expired_Evoucher int,      
  Total_eVoucher int,      
  Redeemed_Winks int,      
  No_Of_Scan int,      
  Total_Redeemed_eVouchers int ,      
  Total_Winks int, 
  total_winks_confiscated int,   
   total_points_confiscated int,  
  Redeemed_Points int,      
  Trip_Points int,      
  alltime_Total_QR_Points int ,      
  alltime_Total_Trip_Points int,      
  alltime_Total_Winks int,      
  alltime_Redeemed_Points int,      
  alltime_Redeemed_Winks int,      
  alltime_total_evoucher int,      
  alltime_total_Redeemed_evoucher int,
  ip_address varchar(50),
  ip_scanned varchar(20),
  total_nets_points int,
  all_time_nets_points int,
  alltime_Confiscated_Points int,      
  alltime_Confiscated_Winks int
 
       
 )    
    
 
 IF (@start_date IS NOT NULL AND @end_date IS NOT NULL AND @start_date!='' AND @end_date !='')      
   IF(@customer_id IS NOT NULL AND @customer_id != '')    
 BEGIN    
 
  ;WITH customer_action_log_temp AS
					(
					   SELECT c_log.customer_id,c_log.customer_action,c_log.ip_address,c_log.id,
							 ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY created_at DESC) AS rn
					   FROM customer_action_log as c_log where c_log.customer_id !=''
					   and c_log.customer_id =@customer_id
					)					
    
		 Insert Into #Customer_Report_Table (customer_id,first_name,last_name,email,status,     
		  Total_QR_Scan_Points, alltime_Total_QR_Points, Expired_Evoucher,Total_eVoucher, alltime_total_evoucher,       
		  Redeemed_Winks, alltime_Redeemed_Winks, No_Of_Scan,Total_Redeemed_eVouchers, alltime_total_Redeemed_evoucher,      
		  Total_Winks,total_winks_confiscated,total_points_confiscated, alltime_Total_Winks, Redeemed_Points,alltime_Redeemed_Points, Trip_Points, 
		  alltime_Total_Trip_Points,ip_address,ip_scanned,total_nets_points,all_time_nets_points,alltime_Confiscated_Points,alltime_Confiscated_Winks)      
		             
		  SELECT customer.customer_id,customer.first_name,customer.last_name,      
			 customer.email ,   customer.status,   
			 (Select ISNULL(SUM(customer_earned_points.points),0) from customer_earned_points       
			  where customer_earned_points.customer_id = customer.customer_id      
			  And CONVERT(CHAR(10),customer_earned_points.created_at,111)       
			  BETWEEN CONVERT(CHAR(10),@start_date,111) and CONVERT(CHAR(10),@end_date,111)      
		      
			 ) As Total_QR_Scan_Points,      
		        
			 (Select ISNULL(SUM(customer_earned_points.points),0) from customer_earned_points       
			  where customer_earned_points.customer_id = customer.customer_id      
			  And CAST(customer_earned_points.created_at as date) <= CAST(@end_date as date)      
		      Group by customer_earned_points.customer_id 
			 ) As alltime_Total_QR_Points,      
		      
		      
			 (select COUNT(*) from customer_earned_evouchers       
			 where customer_earned_evouchers.customer_id = customer.customer_id      
			 AND customer_earned_evouchers.used_status = 0      
			 AND CAST(customer_earned_evouchers.created_at AS DATE) BETWEEN @start_date AND @end_date      
			 AND CAST (customer_earned_evouchers.expired_date AS Date) <= CAST (@CURRENT_DATETIME AS Date)      
		      
			 )      
			 AS Expired_Evoucher,      
		      
			 (select COUNT(*) from customer_earned_evouchers       
			 where customer_earned_evouchers.customer_id = customer.customer_id    
			 --AND customer_earned_evouchers.used_status = 0      
			 AND CAST(customer_earned_evouchers.created_at AS DATE) BETWEEN @start_date AND @end_date      
			 )      
			 AS Total_eVoucher,      
		      
			 (select COUNT(*) from customer_earned_evouchers       
			 where customer_earned_evouchers.customer_id = customer.customer_id      
			 AND CAST(customer_earned_evouchers.created_at AS DATE) <= @end_date      
			 )      
			 AS alltime_total_evoucher,      
		      
			 (select ISNULL(SUM(customer_earned_evouchers.redeemed_winks),0) from customer_earned_evouchers       
			 where customer_earned_evouchers.customer_id = customer.customer_id      
			 --AND customer_earned_evouchers.used_status = 0      
			 AND CAST(customer_earned_evouchers.created_at AS DATE) 
			 >= CAST(@start_date AS DATE) 
			 AND 
			 CAST(customer_earned_evouchers.created_at AS DATE) 
			 <= CAST(@end_date AS DATE) 
			 
			 )      
			 AS Redeemed_Winks,      
		      
			 (select ISNULL(SUM(customer_earned_evouchers.redeemed_winks),0) from customer_earned_evouchers       
			 where customer_earned_evouchers.customer_id = customer.customer_id      
			 --AND customer_earned_evouchers.used_status = 0      
			 AND CAST(customer_earned_evouchers.created_at AS DATE) <= @end_date      
			 )      
			 AS alltime_Redeemed_Winks,      
		      
			 (Select COUNT(*) from customer_earned_points       
			 where customer_earned_points.customer_id = customer.customer_id      
			 AND CAST(customer_earned_points.created_at AS DATE) BETWEEN @start_date AND @end_date      
		      
			 )      
			 AS No_Of_Scan,      
		        
		      
			 (Select COUNT(*) from customer_earned_evouchers where customer_earned_evouchers.customer_id = customer.customer_id      
			 AND customer_earned_evouchers.used_status =1      
			 AND customer_earned_evouchers.created_at BETWEEN @start_date AND @end_date      
			 )       
			 As Total_Redeemed_eVouchers,      
		        
			 (Select COUNT(*) from customer_earned_evouchers where customer_earned_evouchers.customer_id = customer.customer_id      
			 AND customer_earned_evouchers.used_status =1      
			 AND customer_earned_evouchers.created_at <= @end_date      
			 )       
			 As alltime_total_Redeemed_evoucher,      
		           
			 (      
		      
			 Select ISNULL(SUM(customer_earned_winks.total_winks),0) from customer_earned_winks       
			 where customer_earned_winks.customer_id = customer.customer_id      
			 AND CAST (customer_earned_winks.created_at AS date)       
			 BETWEEN CAST (@start_date AS date)  and CAST (@end_date AS date)       
			 GROUP By customer_earned_winks.customer_id      
		      
			 )      
			 AS Total_Winks,  
			 
			 (      
		      
			 Select ISNULL(SUM(wink_confiscated_detail.total_winks),0) from wink_confiscated_detail       
			 where customer.customer_id   =  wink_confiscated_detail.customer_id  
			  -- AND CAST(created_at as date) <= CAST(@end_date as date)

			 AND CAST (wink_confiscated_detail.created_at AS date)       
			 
			 BETWEEN CAST (@start_date AS date)  and CAST (@end_date AS date)       
			 GROUP By wink_confiscated_detail.customer_id      
		     
			 )  
			     
			 AS total_winks_confiscated,     
		     
			(      
		      
			 Select ISNULL(SUM(points_confiscated_detail.confiscated_points),0) from points_confiscated_detail       
			 where customer.customer_id   = points_confiscated_detail.customer_id  
			 --AND CAST (points_confiscated_detail.created_at AS date) <=CAST (@end_date AS date)
			   AND CAST (points_confiscated_detail.created_at AS date)       
			 
			   BETWEEN CAST (@start_date AS date)  and CAST (@end_date AS date)       
			 GROUP By points_confiscated_detail.customer_id      
		      
			 )  
			     
			 AS total_points_confiscated, 
			 			 
			 (      
		      
			 Select ISNULL(SUM(customer_earned_winks.total_winks),0) from customer_earned_winks       
			 where customer_earned_winks.customer_id = customer.customer_id      
			 AND CAST (customer_earned_winks.created_at AS date) <= CAST (@end_date AS date)       
		           
			 GROUP By customer_earned_winks.customer_id      
		      
			 )    
			   
			 AS alltime_Total_Winks,       
		        
			 (      
		      
			 Select ISNULL(SUM(customer_earned_winks.redeemed_points),0) from customer_earned_winks       
			 where customer_earned_winks.customer_id = customer.customer_id      
			 AND CAST (customer_earned_winks.created_at AS date)       
			 BETWEEN CAST (@start_date AS date)  and CAST (@end_date AS date)       
			 GROUP By customer_earned_winks.customer_id      
		      
			 )      
			 AS Redeemed_Points,      
			 (      
		      
			 Select ISNULL(SUM(customer_earned_winks.redeemed_points),0) from customer_earned_winks       
			 where customer_earned_winks.customer_id = customer.customer_id      
			 AND CAST (customer_earned_winks.created_at AS date) <= CAST (@end_date AS date)       
			 GROUP By customer_earned_winks.customer_id      
		      
			 )      
			 AS alltime_Redeemed_Points,      
		      
			 (      
			 /*select SUM(wink_canid_earned_points.total_points) As trip_points from can_id ,wink_canid_earned_points      
			 where can_id.customer_canid = wink_canid_earned_points.can_id      
			 AND CAST (wink_canid_earned_points.created_at AS Date )       
			 BETWEEN CAST (@start_date AS date)  and CAST (@end_date AS date)       
			 and can_id.customer_id = customer.customer_id */      
		           
			 select SUM(wink_canid_earned_points.total_points) As trip_points from wink_canid_earned_points      
			 where customer.customer_id = wink_canid_earned_points.customer_id     
			 AND CAST (wink_canid_earned_points.created_at AS Date )       
			 BETWEEN CAST (@start_date AS date)  and CAST (@end_date AS date)       
		           
		      
			 )      
			 As Trip_Points,      
		      
			 (      
		           
			 select SUM(wink_canid_earned_points.total_points) As trip_points from wink_canid_earned_points      
			 where customer.customer_id = wink_canid_earned_points.customer_id      
			 AND CAST (wink_canid_earned_points.created_at AS date) <= CAST (@end_date AS date)       
		           
			 GROUP By wink_canid_earned_points.customer_id      
		      
			 )        
			 As alltime_Total_Trip_Points,
			 
			 (select top 1 customer_action_log_temp.ip_address from customer_action_log_temp where customer_action_log_temp.customer_id = customer.customer_id order by customer_action_log_temp.id desc) as ip_address
		     ,
		     (select ip_address from (
				select
				ip_address,
       
					 row_number() over(partition by customer_earned_points.customer_id order by created_at desc) as rn
        
				 from
				customer_earned_points 
				where customer.customer_id =  customer_earned_points .customer_id
				and customer_earned_points.ip_address Like LOWER(@ip_scanned+'%')
   
				) t
			  where t.rn = 1) as ip_scanned
		     , 
		      (      
			 /*select SUM(wink_canid_earned_points.total_points) As trip_points from can_id ,wink_canid_earned_points      
			 where can_id.customer_canid = wink_canid_earned_points.can_id      
			 AND CAST (wink_canid_earned_points.created_at AS Date )       
			 BETWEEN CAST (@start_date AS date)  and CAST (@end_date AS date)       
			 and can_id.customer_id = customer.customer_id */      
		           
			 select SUM(wink_net_canid_earned_points.total_points) As trip_points from wink_net_canid_earned_points      
			 where customer.customer_id = wink_net_canid_earned_points.customer_id     
			 AND CAST (wink_net_canid_earned_points.created_at AS Date )       
			 BETWEEN CAST (@start_date AS date)  and CAST (@end_date AS date)       
		           
		      
			 )      
			 As net_Points,      
		     (      
		           
			 select SUM(wink_net_canid_earned_points.total_points) As trip_points from wink_net_canid_earned_points      
			 where customer.customer_id = wink_net_canid_earned_points.customer_id      
			 AND CAST (wink_net_canid_earned_points.created_at AS Date ) <= CAST (@end_date AS date)       
		           
		      
			 )      
			 As all_time_total_net_points,
			 
			  (      
		      
			 Select ISNULL(SUM(wink_confiscated_detail.total_winks),0) from wink_confiscated_detail       
			 where customer.customer_id   =  wink_confiscated_detail.customer_id  
			 AND CAST(created_at as date) <= CAST(@end_date as date)

			  
			 GROUP By wink_confiscated_detail.customer_id      
		     
			 )  
			     
			 AS alltime_Confiscated_Winks , 
			 
			 (      
		      
			 Select ISNULL(SUM(points_confiscated_detail.confiscated_points),0) from points_confiscated_detail       
			 where customer.customer_id   = points_confiscated_detail.customer_id  
			 AND CAST (points_confiscated_detail.created_at AS date) <=CAST (@end_date AS date)
		    
			 GROUP By points_confiscated_detail.customer_id      
		      
			 )  
			     
			 AS alltime_Confiscated_Points
			/*(select Top 1 customer_action_log.ip_address from customer_action_log where customer_action_log.customer_id = customer.customer_id 
			  --and ip_address LIKE '%'+ @ip_address +'%' 
			  order by customer_action_log.id desc) as ip_address  */
		      
		      
			 From customer      
		      WHERE Lower(customer.first_name +' '+ customer.last_name) LIKE Lower('%'+ @customer_name +'%')      
			  AND Lower(customer.email) LIKE Lower('%'+@customer_email+'%')   
			  AND Lower(customer.status) LIKE Lower('%'+@status+'%') 
						  
			  AND Lower(customer.customer_id) = @customer_id 
			   
			 Group By customer.customer_id,customer.first_name,customer.last_name,      
			 customer.email,customer.status order by customer.customer_id desc      
		        
		 END      
       
    ELSE
	BEGIN    
 
  ;WITH customer_action_log_temp AS
					(
					    SELECT *,
							 ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY created_at DESC) AS rn
					   FROM customer_action_log
					  
					)
   
		 Insert Into #Customer_Report_Table (customer_id,first_name,last_name,email,status,     
		  Total_QR_Scan_Points, alltime_Total_QR_Points, Expired_Evoucher,Total_eVoucher, alltime_total_evoucher,       
		  Redeemed_Winks, alltime_Redeemed_Winks, No_Of_Scan,Total_Redeemed_eVouchers, alltime_total_Redeemed_evoucher,      
		  Total_Winks,total_winks_confiscated,total_points_confiscated, alltime_Total_Winks, Redeemed_Points,alltime_Redeemed_Points, Trip_Points, 
		  alltime_Total_Trip_Points,ip_address,ip_scanned,total_nets_points,all_time_nets_points,alltime_Confiscated_Winks,alltime_Confiscated_Points)      
		             
		  SELECT customer.customer_id,customer.first_name,customer.last_name,      
			 customer.email ,   customer.status,   
			 (Select ISNULL(SUM(customer_earned_points.points),0) from customer_earned_points       
			  where customer_earned_points.customer_id = customer.customer_id      
			  And CONVERT(CHAR(10),customer_earned_points.created_at,111)       
			  BETWEEN CONVERT(CHAR(10),@start_date,111) and CONVERT(CHAR(10),@end_date,111)      
		      
			 ) As Total_QR_Scan_Points,      
		        
			 (Select ISNULL(SUM(customer_earned_points.points),0) from customer_earned_points       
			  where customer_earned_points.customer_id = customer.customer_id      
			  AND CAST (customer_earned_points.created_at AS date) <= CAST (@end_date AS date)       
		           
			 GROUP By customer_earned_points.customer_id      
		      
			 )    
			   
			 AS alltime_Total_QR_Points,        
		      
		      
			 (select COUNT(*) from customer_earned_evouchers       
			 where customer_earned_evouchers.customer_id = customer.customer_id      
			 AND customer_earned_evouchers.used_status = 0      
			 AND CAST(customer_earned_evouchers.created_at AS DATE) BETWEEN @start_date AND @end_date      
			 AND CAST (customer_earned_evouchers.expired_date AS Date) <= CAST (@CURRENT_DATETIME AS Date)      
		      
			 )      
			 AS Expired_Evoucher,      
		      
			 (select COUNT(*) from customer_earned_evouchers       
			 where customer_earned_evouchers.customer_id = customer.customer_id    
			 --AND customer_earned_evouchers.used_status = 0      
			 AND CAST(customer_earned_evouchers.created_at AS DATE) BETWEEN @start_date AND @end_date      
			 )      
			 AS Total_eVoucher,      
		      
			 (select COUNT(*) from customer_earned_evouchers       
			 where customer_earned_evouchers.customer_id = customer.customer_id      
			 AND CAST(customer_earned_evouchers.created_at AS DATE) <= @end_date      
			 )      
			 AS alltime_total_evoucher,      
		      
			 (select ISNULL(SUM(customer_earned_evouchers.redeemed_winks),0) from customer_earned_evouchers       
			 where customer_earned_evouchers.customer_id = customer.customer_id      
			 --AND customer_earned_evouchers.used_status = 0      
			 --AND CAST(customer_earned_evouchers.created_at AS DATE) BETWEEN @start_date AND @end_date      
			 AND CAST(customer_earned_evouchers.created_at AS DATE) 
			 >= CAST(@start_date AS DATE) 
			 AND 
			 CAST(customer_earned_evouchers.created_at AS DATE) 
			 <= CAST(@end_date AS DATE) 
			 )      
			 AS Redeemed_Winks,      
		      
			 (select ISNULL(SUM(customer_earned_evouchers.redeemed_winks),0) from customer_earned_evouchers       
			 where customer_earned_evouchers.customer_id = customer.customer_id      
			 --AND customer_earned_evouchers.used_status = 0      
			 AND CAST(customer_earned_evouchers.created_at AS DATE) <= @end_date      
			 )      
			 AS alltime_Redeemed_Winks,      
		      
			 (Select COUNT(*) from customer_earned_points       
			 where customer_earned_points.customer_id = customer.customer_id      
			 AND CAST(customer_earned_points.created_at AS DATE) BETWEEN @start_date AND @end_date      
		      
			 )      
			 AS No_Of_Scan,      
		        
		      
			 (Select COUNT(*) from customer_earned_evouchers where customer_earned_evouchers.customer_id = customer.customer_id      
			 AND customer_earned_evouchers.used_status =1      
			 AND customer_earned_evouchers.created_at BETWEEN @start_date AND @end_date      
			 )       
			 As Total_Redeemed_eVouchers,      
		        
			 (Select COUNT(*) from customer_earned_evouchers where customer_earned_evouchers.customer_id = customer.customer_id      
			 AND customer_earned_evouchers.used_status =1      
			 AND customer_earned_evouchers.created_at <= @end_date      
			 )       
			 As alltime_total_Redeemed_evoucher,      
		           
			 (      
		      
			 Select ISNULL(SUM(customer_earned_winks.total_winks),0) from customer_earned_winks       
			 where customer_earned_winks.customer_id = customer.customer_id      
			 AND CAST (customer_earned_winks.created_at AS date)       
			 BETWEEN CAST (@start_date AS date)  and CAST (@end_date AS date)       
			 GROUP By customer_earned_winks.customer_id      
		      
			 )      
			 AS Total_Winks,  
			 
			 (      
		      
			 Select ISNULL(SUM(wink_confiscated_detail.total_winks),0) from wink_confiscated_detail       
			 where customer.customer_id   =wink_confiscated_detail.customer_id  
			 --AND CAST(created_at as date) <= CAST(@end_date as date)
			 AND CAST (wink_confiscated_detail.created_at AS date)       
			 
			 BETWEEN CAST (@start_date AS date)  and CAST (@end_date AS date)       
			 GROUP By wink_confiscated_detail.customer_id      
		      
			 )  
			     
			 AS total_winks_confiscated,     
		     
			(      
		      
			 Select ISNULL(SUM(points_confiscated_detail.confiscated_points),0) from points_confiscated_detail       
			 where customer.customer_id   = points_confiscated_detail.customer_id 
			-- AND CAST(created_at as date) <= CAST(@end_date as date) 
			AND CAST (points_confiscated_detail.created_at AS date)       
			 
			BETWEEN CAST (@start_date AS date)  and CAST (@end_date AS date)       
			 GROUP By points_confiscated_detail.customer_id      
		      
			 )  
			     
			 AS total_points_confiscated, 
			 			 
			 (      
		      
			 Select ISNULL(SUM(customer_earned_winks.total_winks),0) from customer_earned_winks       
			 where customer_earned_winks.customer_id = customer.customer_id      
			 AND CAST (customer_earned_winks.created_at AS date) <= CAST (@end_date AS date)       
		           
			 GROUP By customer_earned_winks.customer_id      
		      
			 )    
			   
			 AS alltime_Total_Winks,       
		        
			 (      
		      
			 Select ISNULL(SUM(customer_earned_winks.redeemed_points),0) from customer_earned_winks       
			 where customer_earned_winks.customer_id = customer.customer_id      
			 AND CAST (customer_earned_winks.created_at AS date)       
			 BETWEEN CAST (@start_date AS date)  and CAST (@end_date AS date)       
			 GROUP By customer_earned_winks.customer_id      
		      
			 )      
			 AS Redeemed_Points,      
			 (      
		      
			 Select ISNULL(SUM(customer_earned_winks.redeemed_points),0) from customer_earned_winks       
			 where customer_earned_winks.customer_id = customer.customer_id      
			 AND CAST (customer_earned_winks.created_at AS date) <= CAST (@end_date AS date)       
			 GROUP By customer_earned_winks.customer_id      
		      
			 )      
			 AS alltime_Redeemed_Points,      
		      
			 (      
			 /*select SUM(wink_canid_earned_points.total_points) As trip_points from can_id ,wink_canid_earned_points      
			 where can_id.customer_canid = wink_canid_earned_points.can_id      
			 AND CAST (wink_canid_earned_points.created_at AS Date )       
			 BETWEEN CAST (@start_date AS date)  and CAST (@end_date AS date)       
			 and can_id.customer_id = customer.customer_id */      
		           
			 select SUM(wink_canid_earned_points.total_points) As trip_points from wink_canid_earned_points      
			 where customer.customer_id = wink_canid_earned_points.customer_id     
			 AND CAST (wink_canid_earned_points.created_at AS Date )       
			 BETWEEN CAST (@start_date AS date)  and CAST (@end_date AS date)       
		           
		      
			 )      
			 As Trip_Points,      
		      
			 (      
		           
			 select SUM(wink_canid_earned_points.total_points) As trip_points from wink_canid_earned_points      
			 where customer.customer_id = wink_canid_earned_points.customer_id      
			 AND CAST (wink_canid_earned_points.created_at AS Date ) <= CAST (@end_date AS date)       
		     Group by   wink_canid_earned_points.customer_id
		      
			 )      
			 As alltime_Total_Trip_Points,
			 
			 (select top 1 customer_action_log_temp.ip_address from customer_action_log_temp where customer_action_log_temp.customer_id = customer.customer_id order by customer_action_log_temp.created_at desc) as ip_address
		     ,
		     
		       (select ip_address from (
				select
				ip_address,
       
					 row_number() over(partition by customer_earned_points.customer_id order by created_at desc) as rn
        
				 from
				customer_earned_points 
				where customer.customer_id =  customer_earned_points .customer_id
				and customer_earned_points.ip_address Like LOWER(@ip_scanned+'%')
   
				) t
			  where t.rn = 1) as ip_scanned
		     , 
		     
			 (      
			 /*select SUM(wink_canid_earned_points.total_points) As trip_points from can_id ,wink_canid_earned_points      
			 where can_id.customer_canid = wink_canid_earned_points.can_id      
			 AND CAST (wink_canid_earned_points.created_at AS Date )       
			 BETWEEN CAST (@start_date AS date)  and CAST (@end_date AS date)       
			 and can_id.customer_id = customer.customer_id */      
		           
			 select SUM(wink_net_canid_earned_points.total_points) As trip_points from wink_net_canid_earned_points      
			 where customer.customer_id = wink_net_canid_earned_points.customer_id     
			 AND CAST (wink_net_canid_earned_points.created_at AS Date )       
			 BETWEEN CAST (@start_date AS date)  and CAST (@end_date AS date)       
		           
		      
			 )      
			 As net_Points,      
		     (      
		           
			 select SUM(wink_net_canid_earned_points.total_points) As trip_points from wink_net_canid_earned_points      
			 where customer.customer_id = wink_net_canid_earned_points.customer_id      
			 AND CAST (wink_net_canid_earned_points.created_at AS Date ) <= CAST (@end_date AS date)       
		           
		      
			 )      
			 As all_time_total_net_points,
			  (      
		      
			 Select ISNULL(SUM(wink_confiscated_detail.total_winks),0) from wink_confiscated_detail       
			 where customer.customer_id   =  wink_confiscated_detail.customer_id  
			 AND CAST(created_at as date) <= CAST(@end_date as date)

			  
			 GROUP By wink_confiscated_detail.customer_id      
		     
			 )  
			     
			 AS alltime_Confiscated_Winks , 
			 
			 (      
		      
			 Select ISNULL(SUM(points_confiscated_detail.confiscated_points),0) from points_confiscated_detail       
			 where customer.customer_id   = points_confiscated_detail.customer_id  
			 AND CAST (points_confiscated_detail.created_at AS date) <=CAST (@end_date AS date)
		    
			 GROUP By points_confiscated_detail.customer_id      
		      
			 )  
			     
			 AS alltime_Confiscated_Points
			/*(select Top 1 customer_action_log.ip_address from customer_action_log where customer_action_log.customer_id = customer.customer_id 
			  --and ip_address LIKE '%'+ @ip_address +'%' 
			  order by customer_action_log.id desc) as ip_address  */
		      
		      
			 From customer      
		      WHERE Lower(customer.first_name +' '+ customer.last_name) LIKE Lower('%'+ @customer_name +'%')      
			  AND Lower(customer.email) LIKE Lower('%'+@customer_email+'%')   
			  AND Lower(customer.status) LIKE Lower('%'+@status+'%')   
			 Group By customer.customer_id,customer.first_name,customer.last_name,      
			 customer.email,customer.status order by customer.customer_id desc      
		        
		 END      
          
       
ELSE    

IF(@customer_id IS NOT NULL AND @customer_id != '')  
			 BEGIN     
			 Print('Not Date Time Filter')
			;WITH customer_action_log_temp AS
					(
					   SELECT c_log.customer_id,c_log.customer_action,c_log.ip_address,c_log.id,
							 ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY created_at DESC) AS rn
					   FROM customer_action_log as c_log where c_log.customer_id !=''
					   and c_log.customer_id =@customer_id
					)
    
			 Insert Into #Customer_Report_Table (customer_id,first_name,last_name,email, status,     
			  Total_QR_Scan_Points, alltime_Total_QR_Points, Expired_Evoucher,Total_eVoucher, alltime_total_evoucher,       
			  Redeemed_Winks, alltime_Redeemed_Winks, No_Of_Scan,Total_Redeemed_eVouchers, alltime_total_Redeemed_evoucher,      
			  Total_Winks,total_winks_confiscated,total_points_confiscated, alltime_Total_Winks, Redeemed_Points,alltime_Redeemed_Points, Trip_Points,
			   alltime_Total_Trip_Points,ip_address,ip_scanned,total_nets_points,all_time_nets_points,alltime_Confiscated_Winks,alltime_Confiscated_Points) 
			  
  
			   SELECT customer.customer_id,customer.first_name,customer.last_name,      
			   customer.email ,  customer.status,    
			   (Select ISNULL(SUM(customer_earned_points.points),0) from customer_earned_points       
				where customer_earned_points.customer_id = customer.customer_id      
			       
			      
			   ) As Total_QR_Scan_Points,      
			      
			   (Select ISNULL(SUM(customer_earned_points.points),0) from customer_earned_points       
				where customer_earned_points.customer_id = customer.customer_id      
			     
			      
			   ) As alltime_Total_QR_Points,      
			       
			   (select COUNT(*) from customer_earned_evouchers       
				 where customer_earned_evouchers.customer_id = customer.customer_id      
				 AND customer_earned_evouchers.used_status = 0      
				 AND CAST (customer_earned_evouchers.expired_date AS Date) < CAST (@CURRENT_DATETIME AS Date)      
			      
			   )AS Expired_Evoucher,      
			           
			   (select COUNT(*) from customer_earned_evouchers       
			   where customer_earned_evouchers.customer_id = customer.customer_id      
			  
			   )      
			   AS Total_eVoucher,      
			      
			   (select COUNT(*) from customer_earned_evouchers       
			   where customer_earned_evouchers.customer_id = customer.customer_id      
			         
			   )      
			   AS alltime_total_evoucher,      
			       
			   (select ISNULL(SUM(customer_earned_evouchers.redeemed_winks),0) from customer_earned_evouchers       
			   where customer_earned_evouchers.customer_id = customer.customer_id      
			   
			   )      
			   AS Redeemed_Winks,      
			           
			      
			   (select ISNULL(SUM(customer_earned_evouchers.redeemed_winks),0) from customer_earned_evouchers       
			   where customer_earned_evouchers.customer_id = customer.customer_id      
			         
			   )      
			   AS alltime_Redeemed_Winks,      
			      
			   (Select COUNT(*) from customer_earned_points       
			   where customer_earned_points.customer_id = customer.customer_id      
			        
			   )      
			   AS No_Of_Scan,      
			      
			   (Select COUNT(*) from customer_earned_evouchers where customer_earned_evouchers.customer_id = customer.customer_id      
			   AND customer_earned_evouchers.used_status =1      
			            
			   ) As Total_Redeemed_eVouchers,      
			      
			   (Select COUNT(*) from customer_earned_evouchers where customer_earned_evouchers.customer_id = customer.customer_id      
			   AND customer_earned_evouchers.used_status =1      
			                 
			   ) As alltime_total_Redeemed_evoucher,      
			      
			   (      
			      
			   Select ISNULL(SUM(customer_earned_winks.total_winks),0) from customer_earned_winks       
			   where customer_earned_winks.customer_id = customer.customer_id      
				)      
			      
			   AS Total_Winks,  
			   
			   (      
		      
			 Select ISNULL(SUM(wink_confiscated_detail.total_winks),0) from wink_confiscated_detail       
			 where wink_confiscated_detail.customer_id = customer.customer_id      
			    
			 GROUP By wink_confiscated_detail.customer_id      
		      
			 )  
			     
			 AS total_winks_confiscated,    
			 
			 (      
		      
			 Select ISNULL(SUM(points_confiscated_detail.confiscated_points),0) from points_confiscated_detail       
			 where customer.customer_id   = points_confiscated_detail.customer_id  
			 
			 GROUP By points_confiscated_detail.customer_id      
		      
			 )  
			     
			 AS total_points_confiscated,    
			         
			   (      
			      
			   Select ISNULL(SUM(customer_earned_winks.total_winks),0) from customer_earned_winks       
			   where customer_earned_winks.customer_id = customer.customer_id      
			         
			   )      
			      
			   AS alltime_Total_Winks,      
			   (      
			      
			   Select ISNULL(SUM(customer_earned_winks.redeemed_points),0) from customer_earned_winks       
			   where customer_earned_winks.customer_id = customer.customer_id      
			      
			   )      
			   AS Redeemed_Points,      
			       
			   (      
			      
			   Select ISNULL(SUM(customer_earned_winks.redeemed_points),0) from customer_earned_winks       
			   where customer_earned_winks.customer_id = customer.customer_id      
			         
			      
			   )      
			   AS alltime_Redeemed_Points,      
			      
			   (      
			     
				select SUM(wink_canid_earned_points.total_points) As trip_points from wink_canid_earned_points      
				where customer.customer_id = wink_canid_earned_points.customer_id      
			          
			      
			   )      
			   As Trip_Points,      
			      
			      
			   (      
			       
				select SUM(wink_canid_earned_points.total_points) As trip_points from wink_canid_earned_points      
				where customer.customer_id = wink_canid_earned_points.customer_id      
			          
			      
			   )      
			   As alltime_Total_Trip_Points,
			   
			   (select top 1 customer_action_log_temp.ip_address from customer_action_log_temp where customer_action_log_temp.customer_id = customer.customer_id order by customer_action_log_temp.id desc) as ip_address   
			   ,
			     (select ip_address from (
				select
				ip_address,
       
					 row_number() over(partition by customer_earned_points.customer_id order by created_at desc) as rn
        
				 from
				customer_earned_points 
				where customer.customer_id =  customer_earned_points .customer_id
				and customer_earned_points.ip_address Like LOWER(@ip_scanned+'%')
   
				) t
			  where t.rn = 1) as ip_scanned
		     , 
					     
			 (      
			 /*select SUM(wink_canid_earned_points.total_points) As trip_points from can_id ,wink_canid_earned_points      
			 where can_id.customer_canid = wink_canid_earned_points.can_id      
			 AND CAST (wink_canid_earned_points.created_at AS Date )       
			 BETWEEN CAST (@start_date AS date)  and CAST (@end_date AS date)       
			 and can_id.customer_id = customer.customer_id */      
		           
			 select SUM(wink_net_canid_earned_points.total_points) As trip_points from wink_net_canid_earned_points      
			 where customer.customer_id = wink_net_canid_earned_points.customer_id     
			-- AND CAST (wink_net_canid_earned_points.created_at AS Date )       
			-- BETWEEN CAST (@start_date AS date)  and CAST (@end_date AS date)       
		           
		      
			 )      
			 As net_Points,      
		     (      
		           
			 select SUM(wink_net_canid_earned_points.total_points) As trip_points from wink_net_canid_earned_points      
			 where customer.customer_id = wink_net_canid_earned_points.customer_id      
			-- AND CAST (wink_net_canid_earned_points.created_at AS Date ) <= CAST (@end_date AS date)       
		           
		      
			 )      
			 As all_time_total_net_points,
			   (      
		      
			 Select ISNULL(SUM(wink_confiscated_detail.total_winks),0) from wink_confiscated_detail       
			 where wink_confiscated_detail.customer_id = customer.customer_id      
			    
			 GROUP By wink_confiscated_detail.customer_id      
		      
			 )  
			     
			 AS total_winks_confiscated,    
			 
			 (      
		      
			 Select ISNULL(SUM(points_confiscated_detail.confiscated_points),0) from points_confiscated_detail       
			 where customer.customer_id   = points_confiscated_detail.customer_id  
			 
			 GROUP By points_confiscated_detail.customer_id      
		      
			 )  
			     
			 AS total_points_confiscated
			  /*(select Top 1 customer_action_log.ip_address from customer_action_log where customer_action_log.customer_id = customer.customer_id 
				  --and ip_address LIKE '%'+ @ip_address +'%' 
				  order by customer_action_log.id desc) as ip_address   */
			      
			   From customer 
			   WHERE 
			   Lower(customer.first_name +' '+ customer.last_name) LIKE Lower('%'+ @customer_name +'%')      
					AND Lower(customer.email) LIKE Lower('%'+@customer_email+'%')  
					AND Lower(customer.status) LIKE Lower('%'+@status+'%')  
					  
					  AND Lower(customer.customer_id) = @customer_id 

			   Group By customer.customer_id,customer.first_name,customer.last_name,      
			   customer.email,customer.status order by customer.customer_id desc      
			END   

			ELSE
				 BEGIN     
			 
			 ;WITH customer_action_log_temp AS
					(
					   SELECT *,
							 ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY created_at DESC) AS rn
					   FROM customer_action_log
					 
					)
    
			 Insert Into #Customer_Report_Table (customer_id,first_name,last_name,email, status,     
			  Total_QR_Scan_Points, alltime_Total_QR_Points, Expired_Evoucher,Total_eVoucher, alltime_total_evoucher,       
			  Redeemed_Winks, alltime_Redeemed_Winks, No_Of_Scan,Total_Redeemed_eVouchers, alltime_total_Redeemed_evoucher,      
			  Total_Winks,total_winks_confiscated,total_points_confiscated, alltime_Total_Winks, Redeemed_Points,alltime_Redeemed_Points,
			   Trip_Points, alltime_Total_Trip_Points,ip_address,ip_scanned,total_nets_points,all_time_nets_points,alltime_Confiscated_Winks,alltime_Confiscated_Points) 
			  
  
			   SELECT customer.customer_id,customer.first_name,customer.last_name,      
			   customer.email ,  customer.status,    
			   (Select ISNULL(SUM(customer_earned_points.points),0) from customer_earned_points       
				where customer_earned_points.customer_id = customer.customer_id      
			       
			      
			   ) As Total_QR_Scan_Points,      
			      
			   (Select ISNULL(SUM(customer_earned_points.points),0) from customer_earned_points       
				where customer_earned_points.customer_id = customer.customer_id      
			     
			      
			   ) As alltime_Total_QR_Points,      
			       
			   (select COUNT(*) from customer_earned_evouchers       
				 where customer_earned_evouchers.customer_id = customer.customer_id      
				 AND customer_earned_evouchers.used_status = 0      
				 AND CAST (customer_earned_evouchers.expired_date AS Date) < CAST (@CURRENT_DATETIME AS Date)      
			      
			   )AS Expired_Evoucher,      
			           
			   (select COUNT(*) from customer_earned_evouchers       
			   where customer_earned_evouchers.customer_id = customer.customer_id      
			  
			   )      
			   AS Total_eVoucher,      
			      
			   (select COUNT(*) from customer_earned_evouchers       
			   where customer_earned_evouchers.customer_id = customer.customer_id      
			         
			   )      
			   AS alltime_total_evoucher,      
			       
			   (select ISNULL(SUM(customer_earned_evouchers.redeemed_winks),0) from customer_earned_evouchers       
			   where customer_earned_evouchers.customer_id = customer.customer_id      
			   
			   )      
			   AS Redeemed_Winks,      
			           
			      
			   (select ISNULL(SUM(customer_earned_evouchers.redeemed_winks),0) from customer_earned_evouchers       
			   where customer_earned_evouchers.customer_id = customer.customer_id      
			         
			   )      
			   AS alltime_Redeemed_Winks,      
			      
			   (Select COUNT(*) from customer_earned_points       
			   where customer_earned_points.customer_id = customer.customer_id      
			        
			   )      
			   AS No_Of_Scan,      
			      
			   (Select COUNT(*) from customer_earned_evouchers where customer_earned_evouchers.customer_id = customer.customer_id      
			   AND customer_earned_evouchers.used_status =1      
			            
			   ) As Total_Redeemed_eVouchers,      
			      
			   (Select COUNT(*) from customer_earned_evouchers where customer_earned_evouchers.customer_id = customer.customer_id      
			   AND customer_earned_evouchers.used_status =1      
			                 
			   ) As alltime_total_Redeemed_evoucher,      
			      
			   (      
			      
			   Select ISNULL(SUM(customer_earned_winks.total_winks),0) from customer_earned_winks       
			   where customer_earned_winks.customer_id = customer.customer_id      
				)      
			      
			   AS Total_Winks,  
			   
			   (      
		      
			 Select ISNULL(SUM(wink_confiscated_detail.total_winks),0) from wink_confiscated_detail       
			 where wink_confiscated_detail.customer_id = customer.customer_id      
			    
			 GROUP By wink_confiscated_detail.customer_id      
		      
			 )  
			     
			 AS total_winks_confiscated,    
			 
			 (      
		      
			 Select ISNULL(SUM(points_confiscated_detail.confiscated_points),0) from points_confiscated_detail       
			 where customer.customer_id   = points_confiscated_detail.customer_id  
			 --AND CAST (points_confiscated_detail.created_at AS date)       
			 
			 --BETWEEN CAST (@start_date AS date)  and CAST (@end_date AS date)       
			 GROUP By points_confiscated_detail.customer_id      
		      
			 )  
			     
			 AS total_points_confiscated,    
			         
			   (      
			      
			   Select ISNULL(SUM(customer_earned_winks.total_winks),0) from customer_earned_winks       
			   where customer_earned_winks.customer_id = customer.customer_id      
			         
			   )      
			      
			   AS alltime_Total_Winks,      
			   (      
			      
			   Select ISNULL(SUM(customer_earned_winks.redeemed_points),0) from customer_earned_winks       
			   where customer_earned_winks.customer_id = customer.customer_id      
			      
			   )      
			   AS Redeemed_Points,      
			       
			   (      
			      
			   Select ISNULL(SUM(customer_earned_winks.redeemed_points),0) from customer_earned_winks       
			   where customer_earned_winks.customer_id = customer.customer_id      
			         
			      
			   )      
			   AS alltime_Redeemed_Points,      
			      
			   (      
			     
				select SUM(wink_canid_earned_points.total_points) As trip_points from wink_canid_earned_points      
				where customer.customer_id = wink_canid_earned_points.customer_id      
			          
			      
			   )      
			   As Trip_Points,      
			      
			      
			   (      
			       
				select SUM(wink_canid_earned_points.total_points) As trip_points from wink_canid_earned_points      
				where customer.customer_id = wink_canid_earned_points.customer_id      
			          
			      
			   )      
			   As alltime_Total_Trip_Points,
			   
			   (select top 1 customer_action_log_temp.ip_address from customer_action_log_temp where customer_action_log_temp.customer_id = customer.customer_id order by customer_action_log_temp.created_at desc) as ip_address   
			   ,
			   
			 (select ip_address from (
				select
				ip_address,
       
					 row_number() over(partition by customer_earned_points.customer_id order by created_at desc) as rn
        
				 from
				customer_earned_points 
				where customer.customer_id =  customer_earned_points .customer_id
				and customer_earned_points.ip_address Like LOWER(@ip_scanned+'%')
   
				) t
			  where t.rn = 1) as ip_scanned
		     , 
			 	     
			 (      
			 /*select SUM(wink_canid_earned_points.total_points) As trip_points from can_id ,wink_canid_earned_points      
			 where can_id.customer_canid = wink_canid_earned_points.can_id      
			 AND CAST (wink_canid_earned_points.created_at AS Date )       
			 BETWEEN CAST (@start_date AS date)  and CAST (@end_date AS date)       
			 and can_id.customer_id = customer.customer_id */      
		           
			 select SUM(wink_net_canid_earned_points.total_points) As trip_points from wink_net_canid_earned_points      
			 where customer.customer_id = wink_net_canid_earned_points.customer_id     
			 --AND CAST (wink_net_canid_earned_points.created_at AS Date )       
			-- BETWEEN CAST (@start_date AS date)  and CAST (@end_date AS date)       
		           
		      
			 )      
			 As net_Points,      
		     (      
		           
			 select SUM(wink_net_canid_earned_points.total_points) As trip_points from wink_net_canid_earned_points      
			 where customer.customer_id = wink_net_canid_earned_points.customer_id      
			 --AND CAST (wink_net_canid_earned_points.created_at AS Date ) <= CAST (@end_date AS date)       
		           
		      
			 )      
			 As all_time_total_net_points,
			 
			   (      
		      
			 Select ISNULL(SUM(wink_confiscated_detail.total_winks),0) from wink_confiscated_detail       
			 where wink_confiscated_detail.customer_id = customer.customer_id      
			    
			 GROUP By wink_confiscated_detail.customer_id      
		      
			 )  
			     
			 AS total_winks_confiscated,    
			 
			 (      
		      
			 Select ISNULL(SUM(points_confiscated_detail.confiscated_points),0) from points_confiscated_detail       
			 where customer.customer_id   = points_confiscated_detail.customer_id  
			 
			 GROUP By points_confiscated_detail.customer_id      
		      
			 )  
			     
			 AS total_points_confiscated
			  /*(select Top 1 customer_action_log.ip_address from customer_action_log where customer_action_log.customer_id = customer.customer_id 
				  --and ip_address LIKE '%'+ @ip_address +'%' 
				  order by customer_action_log.id desc) as ip_address   */
			      
			   From customer 
			   WHERE 
			   Lower(customer.first_name +' '+ customer.last_name) LIKE Lower('%'+ @customer_name +'%')      
					AND Lower(customer.email) LIKE Lower('%'+@customer_email+'%')  
					AND Lower(customer.status) LIKE Lower('%'+@status+'%')  
					  
			   Group By customer.customer_id,customer.first_name,customer.last_name,      
			   customer.email,customer.status order by customer.customer_id desc      
			END   
	
	
	
			
	-- Check ip address filter
	IF(@ip_address IS NOT NULL AND @ip_address !='')
			BEGIN
		
			IF(@auto_status ='1')
			SELECT * from #Customer_Report_Table 
			WHERE 
			(ISNULL(#Customer_Report_Table.Total_QR_Scan_Points,0)+ ISNULL(#Customer_Report_Table.Trip_Points,0))>0   
			 AND 
			#Customer_Report_Table.ip_address Like @ip_address +'%'	
			AND #Customer_Report_Table.status ='disable' and 
			#Customer_Report_Table.customer_id IN (select customer_id
			from System_Log as s where s.reason !='invalid_login') 	
			--order by (ISNULL(#Customer_Report_Table.Total_QR_Scan_Points,0)+ ISNULL(#Customer_Report_Table.Trip_Points,0)) desc       
			order by (ISNULL(#Customer_Report_Table.No_Of_Scan,0)) desc
	
			ELSE IF (@auto_status ='2')
			BEGIN
			 IF (@start_date IS NOT NULL AND @end_date IS NOT NULL AND @start_date!='' AND @end_date !='')  
			 BEGIN
			 Print('Not Filter IP , login')
			SELECT * from #Customer_Report_Table 
			WHERE 
			#Customer_Report_Table.ip_address Like @ip_address +'%'	
			AND
			#Customer_Report_Table.status ='disable' and 
			#Customer_Report_Table.customer_id IN (select customer_id
			from System_Log AS s where s.reason ='invalid_login' and
			CAST(created_at as DATE) BETWEEN CAST(@start_date as date)  
			And CAST(@end_date as date))
					 
			order by (ISNULL(#Customer_Report_Table.No_Of_Scan,0)) desc
			
			 END
			 ELSE
			 BEGIN
			 Print('Not Filter IP , login')
			SELECT * from #Customer_Report_Table 
			WHERE 
			#Customer_Report_Table.ip_address Like @ip_address +'%'	
			AND
			#Customer_Report_Table.status ='disable' and 
			#Customer_Report_Table.customer_id IN (select customer_id
			from System_Log AS s where s.reason ='invalid_login') 	 		 
			--order by (ISNULL(#Customer_Report_Table.Total_QR_Scan_Points,0)+ ISNULL(#Customer_Report_Table.Trip_Points,0)) desc       
			order by (ISNULL(#Customer_Report_Table.No_Of_Scan,0)) desc
			--order by (ISNULL(#Customer_Report_Table.alltime_Total_QR_Points,0)) desc
			 END
			 
			 
			
			END
			ELSE
			
			SELECT * from #Customer_Report_Table 
			WHERE 
			(ISNULL(#Customer_Report_Table.Total_QR_Scan_Points,0)+ ISNULL(#Customer_Report_Table.Trip_Points,0))>0   
			 AND 
			#Customer_Report_Table.ip_address Like @ip_address +'%'	
			--order by (ISNULL(#Customer_Report_Table.Total_QR_Scan_Points,0)+ ISNULL(#Customer_Report_Table.Trip_Points,0)) desc       
			order by (ISNULL(#Customer_Report_Table.No_Of_Scan,0)) desc
			--order by (ISNULL(#Customer_Report_Table.alltime_Total_QR_Points,0)) desc
			
			END
			
	ELSE IF(@ip_scanned IS NOT NULL AND @ip_scanned !='')
			BEGIN
		
			IF(@auto_status ='1')
			SELECT * from #Customer_Report_Table 
			WHERE 
			(ISNULL(#Customer_Report_Table.Total_QR_Scan_Points,0)+ ISNULL(#Customer_Report_Table.Trip_Points,0))>0   
			 AND 
			#Customer_Report_Table.ip_scanned Like  Lower(@ip_scanned+'%') 
			AND #Customer_Report_Table.status ='disable' and 
			#Customer_Report_Table.customer_id IN (select customer_id
			from System_Log as s where s.reason !='invalid_login') 	
			      
			order by (ISNULL(#Customer_Report_Table.No_Of_Scan,0)) desc
	
			ELSE IF (@auto_status ='2')
			BEGIN
			 IF (@start_date IS NOT NULL AND @end_date IS NOT NULL AND @start_date!='' AND @end_date !='')  
			 BEGIN
			 Print('Not Filter IP , login')
			SELECT * from #Customer_Report_Table 
			WHERE 
			#Customer_Report_Table.ip_scanned Like  Lower(@ip_scanned+'%') 
			AND
			#Customer_Report_Table.status ='disable' and 
			#Customer_Report_Table.customer_id IN (select customer_id
			from System_Log AS s where s.reason ='invalid_login' and
			CAST(created_at as DATE) BETWEEN CAST(@start_date as date)  
			And CAST(@end_date as date))
					 
			order by (ISNULL(#Customer_Report_Table.No_Of_Scan,0)) desc
			
			 END
			 ELSE
			 BEGIN
			 Print('Not Filter IP , login')
			SELECT * from #Customer_Report_Table 
			WHERE 
			#Customer_Report_Table.ip_scanned Like  Lower(@ip_scanned+'%') 	
			AND
			#Customer_Report_Table.status ='disable' and 
			#Customer_Report_Table.customer_id IN (select customer_id
			from System_Log AS s where s.reason ='invalid_login') 	 		 
			      
			order by (ISNULL(#Customer_Report_Table.No_Of_Scan,0)) desc
			--order by (ISNULL(#Customer_Report_Table.alltime_Total_QR_Points,0)) desc
			 END
			 
			 
			
			END
			ELSE
			
			SELECT * from #Customer_Report_Table 
			WHERE 
			(ISNULL(#Customer_Report_Table.Total_QR_Scan_Points,0)+ ISNULL(#Customer_Report_Table.Trip_Points,0))>0   
			 AND 
			#Customer_Report_Table.ip_scanned Like  Lower(@ip_scanned+'%') 
			
			order by (ISNULL(#Customer_Report_Table.No_Of_Scan,0)) desc
			--order by (ISNULL(#Customer_Report_Table.alltime_Total_QR_Points,0)) desc
			
			END		
	
	ELSE 
			BEGIN
			IF (@auto_status ='1')
			SELECT * from #Customer_Report_Table 
			WHERE (ISNULL(#Customer_Report_Table.Total_QR_Scan_Points,0)+ ISNULL(#Customer_Report_Table.Trip_Points,0))>0   
			AND #Customer_Report_Table.status ='disable' and 
			#Customer_Report_Table.customer_id IN (select customer_id
			from System_Log AS s where s.reason !='invalid_login') 	 		 
			--order by (ISNULL(#Customer_Report_Table.Total_QR_Scan_Points,0)+ ISNULL(#Customer_Report_Table.Trip_Points,0)) desc       
			order by (ISNULL(#Customer_Report_Table.No_Of_Scan,0)) desc
			--order by (ISNULL(#Customer_Report_Table.alltime_Total_QR_Points,0)) desc
			ELSE IF (@auto_status ='2')
			BEGIN
			 IF (@start_date IS NOT NULL AND @end_date IS NOT NULL AND @start_date!='' AND @end_date !='')  
			 BEGIN
			 Print('Not Filter IP , login')
			SELECT * from #Customer_Report_Table 
			WHERE 
			--(ISNULL(#Customer_Report_Table.Total_QR_Scan_Points,0)+ ISNULL(#Customer_Report_Table.Trip_Points,0))>0   
			--AND 
			#Customer_Report_Table.status ='disable' and 
			#Customer_Report_Table.customer_id IN (select customer_id
			from System_Log AS s where s.reason ='invalid_login' and
			CAST(created_at as DATE) BETWEEN CAST(@start_date as date)  And CAST(@end_date as date))		 
			order by (ISNULL(#Customer_Report_Table.No_Of_Scan,0)) desc
			
			 END
			 ELSE
			 BEGIN
			 Print('Not Filter IP , login')
			SELECT * from #Customer_Report_Table 
			WHERE 
			--(ISNULL(#Customer_Report_Table.Total_QR_Scan_Points,0)+ ISNULL(#Customer_Report_Table.Trip_Points,0))>0   
			--AND 
			#Customer_Report_Table.status ='disable' and 
			#Customer_Report_Table.customer_id IN (select customer_id
			from System_Log AS s where s.reason ='invalid_login') 	 		 
			--order by (ISNULL(#Customer_Report_Table.Total_QR_Scan_Points,0)+ ISNULL(#Customer_Report_Table.Trip_Points,0)) desc       
			order by (ISNULL(#Customer_Report_Table.No_Of_Scan,0)) desc
			--order by (ISNULL(#Customer_Report_Table.alltime_Total_QR_Points,0)) desc
			 END
			 
			 
			
			END
			ELSE
			BEGIN
			Print('Not Auto Status and IP address filter')
			SELECT * from #Customer_Report_Table 
			WHERE (ISNULL(#Customer_Report_Table.Total_QR_Scan_Points,0)+ ISNULL(#Customer_Report_Table.Trip_Points,0))>0   
					 
			--order by (ISNULL(#Customer_Report_Table.Total_QR_Scan_Points,0)+ ISNULL(#Customer_Report_Table.Trip_Points,0)) desc       
			order by (ISNULL(#Customer_Report_Table.No_Of_Scan,0)) desc
			--order by (ISNULL(#Customer_Report_Table.alltime_Total_QR_Points,0)) desc
			END
			END
			
		
             
END      

      
    
      
      
      







