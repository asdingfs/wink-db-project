CREATE PROCEDURE [dbo].[Get_Customer_Report_With_IP_bak15042016]      
 (@start_date datetime,      
  @end_date datetime,      
  @customer_name varchar(150),      
  @customer_email varchar(150),
  @ip_address varchar(50),
  @status varchar(10)
  
  )      
AS      
BEGIN      
Declare @CURRENT_DATETIME Datetime      
EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUTPUT      

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
     
  Redeemed_Points int,      
  Trip_Points int,   
      
  alltime_Total_QR_Points int ,      
  alltime_Total_Trip_Points int,      
  alltime_Total_Winks int,      
  alltime_Redeemed_Points int,      
  alltime_Redeemed_Winks int,      
  alltime_total_evoucher int,      
  alltime_total_Redeemed_evoucher int,
  ip_address varchar(50)
 
       
 )      
 print (@start_date)
    
print (@end_date)
 IF (@start_date IS NOT NULL AND @end_date IS NOT NULL AND @start_date!='' AND @end_date !='')      
       
 BEGIN      
		 Insert Into #Customer_Report_Table (customer_id,first_name,last_name,email,status,     
		  Total_QR_Scan_Points, alltime_Total_QR_Points, Expired_Evoucher,Total_eVoucher, alltime_total_evoucher,       
		  Redeemed_Winks, alltime_Redeemed_Winks, No_Of_Scan,Total_Redeemed_eVouchers, alltime_total_Redeemed_evoucher,      
		  Total_Winks,total_winks_confiscated, alltime_Total_Winks, Redeemed_Points,alltime_Redeemed_Points, Trip_Points, alltime_Total_Trip_Points,ip_address)      
		             
		  SELECT customer.customer_id,customer.first_name,customer.last_name,      
			 customer.email ,   customer.status,   
			 (Select ISNULL(SUM(customer_earned_points.points),0) from customer_earned_points       
			  where customer_earned_points.customer_id = customer.customer_id      
			  And CONVERT(CHAR(10),customer_earned_points.created_at,111)       
			  BETWEEN CONVERT(CHAR(10),@start_date,111) and CONVERT(CHAR(10),@end_date,111)      
		      
			 ) As Total_QR_Scan_Points,      
		        
			 (Select ISNULL(SUM(customer_earned_points.points),0) from customer_earned_points       
			  where customer_earned_points.customer_id = customer.customer_id      
			  And CONVERT(CHAR(10),customer_earned_points.created_at,111) <= CONVERT(CHAR(10),@end_date,111)      
		      
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
			 AND CAST(customer_earned_evouchers.created_at AS DATE) BETWEEN @start_date AND @end_date      
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
			 AND CAST (wink_confiscated_detail.created_at AS date)       
			 
			 BETWEEN CAST (@start_date AS date)  and CAST (@end_date AS date)       
			 GROUP By wink_confiscated_detail.customer_id      
		      
			 )  
			     
			 AS total_winks_confiscated,     
		     
						 
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
		           
		      
			 )      
			 As alltime_Total_Trip_Points,
		     
			(select Top 1 customer_action_log.ip_address from customer_action_log where customer_action_log.customer_id = customer.customer_id 
			  --and ip_address LIKE '%'+ @ip_address +'%' 
			  order by customer_action_log.id desc) as ip_address  
		      
		      
			 From customer      
		      WHERE Lower(customer.first_name +' '+ customer.last_name) LIKE Lower('%'+ @customer_name +'%')      
			  AND Lower(customer.email) LIKE Lower('%'+@customer_email+'%')   
			  AND Lower(customer.status) LIKE Lower('%'+@status+'%')   
			 Group By customer.customer_id,customer.first_name,customer.last_name,      
			 customer.email,customer.status order by customer.customer_id desc      
		        
		 END      
       
       
       
ELSE      
			 BEGIN      
			      
			 Insert Into #Customer_Report_Table (customer_id,first_name,last_name,email, status,     
			  Total_QR_Scan_Points, alltime_Total_QR_Points, Expired_Evoucher,Total_eVoucher, alltime_total_evoucher,       
			  Redeemed_Winks, alltime_Redeemed_Winks, No_Of_Scan,Total_Redeemed_eVouchers, alltime_total_Redeemed_evoucher,      
			  Total_Winks,total_winks_confiscated, alltime_Total_Winks, Redeemed_Points,alltime_Redeemed_Points, Trip_Points, alltime_Total_Trip_Points,ip_address)      
			      
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
			  (select Top 1 customer_action_log.ip_address from customer_action_log where customer_action_log.customer_id = customer.customer_id 
				  --and ip_address LIKE '%'+ @ip_address +'%' 
				  order by customer_action_log.id desc) as ip_address        
			      
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
			print(@ip_address)
			SELECT * from #Customer_Report_Table 
			WHERE 
			(ISNULL(#Customer_Report_Table.Total_QR_Scan_Points,0)+ ISNULL(#Customer_Report_Table.Trip_Points,0))>0   
			 AND 
			#Customer_Report_Table.ip_address Like @ip_address +'%'		 
			order by (ISNULL(#Customer_Report_Table.Total_QR_Scan_Points,0)+ ISNULL(#Customer_Report_Table.Trip_Points,0)) desc       
			END
			
			
	
	ELSE 
			BEGIN
			SELECT * from #Customer_Report_Table 
			WHERE (ISNULL(#Customer_Report_Table.Total_QR_Scan_Points,0)+ ISNULL(#Customer_Report_Table.Trip_Points,0))>0   
					 
			order by (ISNULL(#Customer_Report_Table.Total_QR_Scan_Points,0)+ ISNULL(#Customer_Report_Table.Trip_Points,0)) desc       
			END
	

 /*-----------------------Start Filter ----------------------------------*/   
              
  /*  IF (@start_date IS NOT NULL AND @end_date IS NOT NULL AND @start_date!='' AND @end_date !='')  
		BEGIN  --Begin Date Filter
			--Check Name And Email      
			IF (@customer_name IS NOT NULL AND @customer_name !='' AND @customer_email IS NOT NULL AND @customer_email !='')      
			 BEGIN      
			  SELECT * FROM #Customer_Report_Table      
			  WHERE Lower(#Customer_Report_Table.first_name +' '+ #Customer_Report_Table.last_name) LIKE Lower('%'+ @customer_name +'%')      
			  AND Lower(#Customer_Report_Table.email) LIKE Lower('%'+@customer_email+'%')  
			  AND (ISNULL(#Customer_Report_Table.Total_QR_Scan_Points,0)+ ISNULL(#Customer_Report_Table.Trip_Points,0))>0   
			 -- order by #Customer_Report_Table.customer_id desc
			 order by (ISNULL(#Customer_Report_Table.Total_QR_Scan_Points,0)+ ISNULL(#Customer_Report_Table.Trip_Points,0)) desc       
		        
		      
			 END      
			-- Check Email      
			ELSE IF (@customer_email IS NOT NULL AND @customer_email !='')      
			 BEGIN      
			  SELECT * FROM #Customer_Report_Table       
			  WHERE Lower(#Customer_Report_Table.email) LIKE Lower('%'+@customer_email+'%')  
			 AND (ISNULL(#Customer_Report_Table.Total_QR_Scan_Points,0)+ ISNULL(#Customer_Report_Table.Trip_Points,0))>0   
			 -- order by #Customer_Report_Table.customer_id desc
			 order by (ISNULL(#Customer_Report_Table.Total_QR_Scan_Points,0)+ ISNULL(#Customer_Report_Table.Trip_Points,0)) desc       
		           
			 END      
			-- Check Name      
		          
			ELSE IF (@customer_name IS NOT NULL AND @customer_name !='')      
			 BEGIN      
			  SELECT * FROM #Customer_Report_Table       
			  WHERE Lower(#Customer_Report_Table.first_name +' '+ #Customer_Report_Table.last_name) LIKE Lower('%'+ @customer_name +'%')      
			 AND (ISNULL(#Customer_Report_Table.Total_QR_Scan_Points,0)+ ISNULL(#Customer_Report_Table.Trip_Points,0))>0   
			 -- order by #Customer_Report_Table.customer_id desc
			 order by (ISNULL(#Customer_Report_Table.Total_QR_Scan_Points,0)+ ISNULL(#Customer_Report_Table.Trip_Points,0)) desc        
		           
			 END       
			ELSE       
			 BEGIN   
			
			  SELECT * FROM #Customer_Report_Table
			  WHERE (ISNULL(#Customer_Report_Table.Total_QR_Scan_Points,0)+ ISNULL(#Customer_Report_Table.Trip_Points,0))>0   
			 -- order by #Customer_Report_Table.customer_id desc
			  order by (ISNULL(#Customer_Report_Table.Total_QR_Scan_Points,0)+ ISNULL(#Customer_Report_Table.Trip_Points,0)) desc       
		           
			 END   
		     
		END     -- End Date Filter  
	ELSE
		BEGIN  --No Date Filter
			Print('No Date Filter')					--Check Name And Email      
			IF (@customer_name IS NOT NULL AND @customer_name !='' AND @customer_email IS NOT NULL AND @customer_email !='')      
			 BEGIN      
			  SELECT * FROM #Customer_Report_Table      
			  WHERE Lower(#Customer_Report_Table.first_name +' '+ #Customer_Report_Table.last_name) LIKE Lower('%'+ @customer_name +'%')      
			  AND Lower(#Customer_Report_Table.email) LIKE Lower('%'+@customer_email+'%') 
			  AND (ISNULL(#Customer_Report_Table.alltime_Total_QR_Points,0) + ISNULL(#Customer_Report_Table.alltime_Total_Trip_Points,0))>0     
			 -- order by #Customer_Report_Table.customer_id desc
			 order by (ISNULL(#Customer_Report_Table.alltime_Total_QR_Points,0)+ ISNULL(#Customer_Report_Table.alltime_Total_Trip_Points,0)) desc       
		        
		      
			 END      
			-- Check Email      
			ELSE IF (@customer_email IS NOT NULL AND @customer_email !='')      
			 BEGIN      
			  SELECT * FROM #Customer_Report_Table       
			  WHERE Lower(#Customer_Report_Table.email) LIKE Lower('%'+@customer_email+'%')  
			  AND (ISNULL(#Customer_Report_Table.alltime_Total_QR_Points,0) + ISNULL(#Customer_Report_Table.alltime_Total_Trip_Points,0))>0     
			 -- order by #Customer_Report_Table.customer_id desc
			 order by (ISNULL(#Customer_Report_Table.alltime_Total_QR_Points,0)+ ISNULL(#Customer_Report_Table.alltime_Total_Trip_Points,0)) desc       
		           
			 END      
			-- Check Name      
		          
			ELSE IF (@customer_name IS NOT NULL AND @customer_name !='')      
			 BEGIN      
			  SELECT * FROM #Customer_Report_Table       
			  WHERE Lower(#Customer_Report_Table.first_name +' '+ #Customer_Report_Table.last_name) LIKE Lower('%'+ @customer_name +'%')      
			  AND (ISNULL(#Customer_Report_Table.alltime_Total_QR_Points,0) + ISNULL(#Customer_Report_Table.alltime_Total_Trip_Points,0))>0     
			 -- order by #Customer_Report_Table.customer_id desc
			 order by (ISNULL(#Customer_Report_Table.alltime_Total_QR_Points,0)+ ISNULL(#Customer_Report_Table.alltime_Total_Trip_Points,0)) desc       
		           
			 END       
			ELSE       
			 BEGIN    
			
			  SELECT * FROM #Customer_Report_Table   
			  WHERE (ISNULL(#Customer_Report_Table.alltime_Total_QR_Points,0) + ISNULL(#Customer_Report_Table.alltime_Total_Trip_Points,0))>0     
			 -- order by #Customer_Report_Table.customer_id desc
			 order by (ISNULL(#Customer_Report_Table.alltime_Total_QR_Points,0)+ ISNULL(#Customer_Report_Table.alltime_Total_Trip_Points,0)) desc       
		           
			 END   
     
		END     -- End No Date Filter  
    */
             
END      
      
 
      
      
      
