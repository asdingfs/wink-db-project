Create PROCEDURE [dbo].[Get_Customer_Report_With_Paging_v01]      
 (--@start_date datetime,      
  --@end_date datetime,      
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
    
     print ('@intStartRow')
    print (@intStartRow)
    print  ('@intEndRow')
    print  (@intEndRow)
    
     
Declare @CURRENT_DATETIME Datetime      
EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUTPUT   
DECLARE @auto_status varchar(5)     

BEGIN

IF (@customer_name is null or @customer_name = '')
 BEGIN
 SET @customer_name = NULL;
 
 END
IF (@customer_email is null or @customer_email = '')
 BEGIN
 SET @customer_email = NULL;
 
 END
IF (@status is null or @status = '')
 BEGIN
 SET @status = NULL;
 
 END
IF (@ip_scanned is null or @ip_scanned = '')
 BEGIN
 SET @ip_scanned = NULL;
 
 END
IF (@ip_address is null or @ip_address = '')
 BEGIN
 SET @ip_address = NULL;
 
 END
IF (@customer_id is null or @customer_id = '')
 BEGIN
 SET @customer_id = NULL;
 
 END


select f.customer_id,f.total_points,f.total_winks,f.total_used_evouchers,
					 f.used_points,f.used_winks,f.confiscated_points,
					 f.confiscated_winks,f.expired_winks,
					  f.first_name,f.last_name ,f.email,f.status,f.ip_address,f.ip_scanned,
					  intRow,total_count,
					 ISNULL(f.total_evouchers ,0) - ISNULL(f.total_used_evouchers,0) - ISNULL(Expired_Evoucher,0) as balanced_evouchers
					 ,ISNULL(f.total_points,0) - ISNULL(f.used_points,0) -ISNULL(f.confiscated_points,0) as balanced_points
					 ,ISNULL(f.total_winks,0) - ISNULL(f.used_winks,0) -ISNULL(f.confiscated_winks,0) as balanced_winks
					  ,ISNULl (Expired_Evoucher,0) as Expired_Evoucher,
					   ISNULL (total_evouchers,0) as Total_eVoucher , 
					   ISNULL (No_Of_Scan,0) as No_Of_Scan,
					   ISNULL(Total_Winks,0) as Total_Winks,
					   ISNULL (confiscated_winks,0) as total_winks_confiscated,
					   ISNULL (confiscated_points,0) as total_points_confiscated,
					     ISNULL(used_winks,0) as Redeemed_Winks
				
					 
					   from
                    ( select * from
 
					(select c.customer_id,c.total_points,c.total_winks,c.total_used_evouchers,
					 c.used_points,c.used_winks,c.confiscated_points,c.total_evouchers,
					 c.confiscated_winks,c.expired_winks,
					  c.first_name,c.last_name ,c.email,c.status,c.ip_address,c.ip_scanned,
					  ROW_NUMBER() OVER(ORDER BY isnull(No_Of_Scan,0) DESC) as intRow,
					  total_count ,
					  ISNULL(No_Of_Scan,0) as No_Of_Scan
					  
					  
					   from 
					  

					(select a.customer_id,a.total_points,a.total_winks,a.total_used_evouchers,
					 a.used_points,a.used_winks,a.confiscated_points,a.total_evouchers,
					 a.confiscated_winks,a.expired_winks,COUNT(*) OVER() AS total_count,
					  b.first_name,b.last_name ,b.email,b.status,b.ip_address,b.ip_scanned
					   
					   
					  from customer_balance as a
					 join customer as b
					 on a.customer_id = b.customer_id
					 where a.customer_id != 15
					 and (@customer_name IS NULL OR Lower(b.first_name +' '+ b.last_name) LIKE Lower(@customer_name +'%'))      
					 AND (@customer_email IS NULL OR Lower(b.email) LIKE Lower(@customer_email+'%'))   
					 AND (@status IS NULL OR Lower(b.status) LIKE Lower('%'+@status+'%'))
					 and (@ip_scanned IS NULL OR b.ip_scanned = @ip_scanned)
					 and (@ip_address IS NULL OR b.ip_address = @ip_address)
					 and (@customer_id IS NULL OR a.customer_id = @customer_id)
					    
					 )
					 as c
					 left join 
					 (
					 select count(*) as No_Of_Scan ,customer_id 
					
										  from customer_earned_points 
											Group by customer_id
                     						Having COUNT(*)>0
					   ) as d
					   on d.customer_id = c.customer_id
					  
					   ) as e
					   where e.intRow between @intStartRow and @intEndRow
					   ) as f
						left Join 
                     -----------------------------------
					(select COUNT(*) AS 

						Expired_Evoucher,customer_id from customer_earned_evouchers 
						where CAST (customer_earned_evouchers.expired_date AS 
						Date) <= CAST (@CURRENT_DATETIME AS Date)  
						and customer_earned_evouchers.used_status=0         
			  
					    Group By customer_id 
			        
			        )as expired_eVouchers_temp
			        
			        on f.customer_id = expired_eVouchers_temp.customer_id
			        where ISNULL(f.total_evouchers ,0) - ISNULL(f.total_used_evouchers,0) - ISNULL(Expired_Evoucher,0)>=0
			        and ISNULL(f.total_points,0) - ISNULL(f.used_points,0) -ISNULL(f.confiscated_points,0)>=0
			        and ISNULL(f.total_winks,0) - ISNULL(f.used_winks,0) -ISNULL(f.confiscated_winks,0)>=0
			        order by intRow 


	END
 
END



