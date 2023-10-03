Create PROCEDURE [dbo].[Get_Customer_Report_testing]
	(@start_date datetime,
	 @end_date datetime,
	 @customer_name varchar(150),
	 @customer_email varchar(150))
AS
BEGIN
Declare @CURRENT_DATETIME Datetime
EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUTPUT
-- Date Time Filter
	IF OBJECT_ID('tempdb..#Customer_Report_Table_TimeFilter') IS NOT NULL DROP TABLE #Customer_Report_Table_TimeFilter

	CREATE TABLE #Customer_Report_Table_TimeFilter
	(
	 customer_id int,
	 first_name varchar(200),
	 last_name varchar(200),
	 email varchar(100),
	 Total_QR_Scan_Points int,
	 Expired_Evoucher int,
	 Total_eVoucher int,
	 Redeemed_Winks int,
	 No_Of_Scan int,
	 Total_Redeemed_eVouchers int ,
	 Total_Winks int,
	 Redeemed_Points int,
	 Trip_Points int
 
	)
-- Without Date Time Filter
	IF OBJECT_ID('tempdb..#Customer_Report_Table') IS NOT NULL DROP TABLE #Customer_Report_Table

	CREATE TABLE #Customer_Report_Table
	(
	 customer_id int,
	 first_name varchar(200),
	 last_name varchar(200),
	 email varchar(100),
	 Total_QR_Scan_Points int,
	 Expired_Evoucher int,
	 Total_eVoucher int,
	 Redeemed_Winks int,
	 No_Of_Scan int,
	 Total_Redeemed_eVouchers int ,
	 Total_Winks int,
	 Redeemed_Points int,
	 Trip_Points int
 
	)

	IF (@start_date IS NOT NULL AND @end_date IS NOT NULL AND @start_date!='' AND @end_date !='')
	
	BEGIN
		Insert Into #Customer_Report_Table_TimeFilter (customer_id,first_name,last_name,email,
		Total_QR_Scan_Points,Expired_Evoucher,Total_eVoucher,Redeemed_Winks,No_Of_Scan,Total_Redeemed_eVouchers,
		Total_Winks,Redeemed_Points,Trip_Points)					
		SELECT customer.customer_id,customer.first_name,customer.last_name,
					customer.email ,
					(Select ISNULL(SUM(customer_earned_points.points),0) from customer_earned_points 
					 where customer_earned_points.customer_id = customer.customer_id
					 And CONVERT(CHAR(10),customer_earned_points.created_at,111) 
					 BETWEEN CONVERT(CHAR(10),@start_date,111) and CONVERT(CHAR(10),@end_date,111)

					) As Total_QR_Scan_Points,
		
		
					(select COUNT(*) from customer_earned_evouchers 
					where customer_earned_evouchers.customer_id = customer.customer_id
					AND customer_earned_evouchers.used_status = 0
					AND CAST(customer_earned_evouchers.created_at AS DATE) BETWEEN @start_date AND @end_date
					AND CAST (customer_earned_evouchers.expired_date AS Date) < CAST (@CURRENT_DATETIME AS Date)

					)
					AS Expired_Evoucher,

					(select COUNT(*) from customer_earned_evouchers 
					where customer_earned_evouchers.customer_id = customer.customer_id
					--AND customer_earned_evouchers.used_status = 0
					AND CAST(customer_earned_evouchers.created_at AS DATE) BETWEEN @start_date AND @end_date
					)
					AS Total_eVoucher,

					(select ISNULL(SUM(customer_earned_evouchers.redeemed_winks),0) from customer_earned_evouchers 
					where customer_earned_evouchers.customer_id = customer.customer_id
					--AND customer_earned_evouchers.used_status = 0
					AND CAST(customer_earned_evouchers.created_at AS DATE) BETWEEN @start_date AND @end_date
					)
					AS Redeemed_Winks,

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
		
					(

					Select ISNULL(SUM(customer_earned_winks.total_winks),0) from customer_earned_winks 
					where customer_earned_winks.customer_id = customer.customer_id
					AND CAST (customer_earned_winks.created_at AS date) 
					BETWEEN CAST (@start_date AS date)  and CAST (@end_date AS date) 
					GROUP By customer_earned_winks.customer_id

					)
					AS Total_Winks,
		
					(

					Select ISNULL(SUM(customer_earned_winks.redeemed_points),0) from customer_earned_winks 
					where customer_earned_winks.customer_id = customer.customer_id
					AND CAST (customer_earned_winks.created_at AS date) 
					BETWEEN CAST (@start_date AS date)  and CAST (@end_date AS date) 
					GROUP By customer_earned_winks.customer_id

					)
					AS Redeemed_Points,
		
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
					As Trip_Points

					From customer
	
					Group By customer.customer_id,customer.first_name,customer.last_name,
					customer.email order by customer.customer_id desc
		
	END
	
	
	
ELSE
	BEGIN
	Insert Into #Customer_Report_Table (customer_id,first_name,last_name,email,
		Total_QR_Scan_Points,Expired_Evoucher,Total_eVoucher,Redeemed_Winks,No_Of_Scan,Total_Redeemed_eVouchers,
		Total_Winks,Redeemed_Points,Trip_Points)
			SELECT customer.customer_id,customer.first_name,customer.last_name,
			customer.email ,
			(Select ISNULL(SUM(customer_earned_points.points),0) from customer_earned_points 
			 where customer_earned_points.customer_id = customer.customer_id
			--And CONVERT(CHAR(10),customer_earned_points.created_at,111) 
			--BETWEEN CONVERT(CHAR(10),@start_date,111) and CONVERT(CHAR(10),@end_date,111)

			) As Total_QR_Scan_Points,
	
			(select COUNT(*) from customer_earned_evouchers 
					where customer_earned_evouchers.customer_id = customer.customer_id
					AND customer_earned_evouchers.used_status = 0
					--AND CAST(customer_earned_evouchers.created_at AS DATE) BETWEEN @start_date AND @end_date
					AND CAST (customer_earned_evouchers.expired_date AS Date) < CAST (@CURRENT_DATETIME AS Date)

			)AS Expired_Evoucher,
					
			(select COUNT(*) from customer_earned_evouchers 
			where customer_earned_evouchers.customer_id = customer.customer_id
			--AND customer_earned_evouchers.used_status = 0
			--AND CAST(customer_earned_evouchers.created_at AS DATE) BETWEEN @start_date AND @end_date
			)
			AS Total_eVoucher,
	
			(select ISNULL(SUM(customer_earned_evouchers.redeemed_winks),0) from customer_earned_evouchers 
			where customer_earned_evouchers.customer_id = customer.customer_id
			--AND customer_earned_evouchers.used_status = 0
			--AND CAST(customer_earned_evouchers.created_at AS DATE) BETWEEN @start_date AND @end_date
			)
			AS Redeemed_Winks,

			(Select COUNT(*) from customer_earned_points 
			where customer_earned_points.customer_id = customer.customer_id
			--AND CAST(customer_earned_points.created_at AS DATE) BETWEEN @start_date AND @end_date

			)
			AS No_Of_Scan,

			(Select COUNT(*) from customer_earned_evouchers where customer_earned_evouchers.customer_id = customer.customer_id
			AND customer_earned_evouchers.used_status =1
			--AND customer_earned_evouchers.created_at BETWEEN @start_date AND @end_date


			) As Total_Redeemed_eVouchers,
			(

			Select ISNULL(SUM(customer_earned_winks.total_winks),0) from customer_earned_winks 
			where customer_earned_winks.customer_id = customer.customer_id
			--AND CAST (customer_earned_winks.created_at AS date) 
			--BETWEEN CAST (@start_date AS date)  and CAST (@end_date AS date) 
			--GROUP By customer_earned_winks.customer_id
			)

			AS Total_Winks,
			(

			Select ISNULL(SUM(customer_earned_winks.redeemed_points),0) from customer_earned_winks 
			where customer_earned_winks.customer_id = customer.customer_id
			--AND CAST (customer_earned_winks.created_at AS date) 
			--BETWEEN CAST (@start_date AS date)  and CAST (@end_date AS date) 
			--GROUP By customer_earned_winks.customer_id

			)
			AS Redeemed_Points,
	
			(
				/*select SUM(wink_canid_earned_points.total_points) As trip_points from can_id ,wink_canid_earned_points
				where can_id.customer_canid = wink_canid_earned_points.can_id
				and can_id.customer_id = customer.customer_id*/ 
				select SUM(wink_canid_earned_points.total_points) As trip_points from wink_canid_earned_points
				where customer.customer_id = wink_canid_earned_points.customer_id
				

			)
			As Trip_Points

			From customer 
			Group By customer.customer_id,customer.first_name,customer.last_name,
			customer.email order by customer.customer_id desc
END

	-- Check email and name 
		-- For With Date Time
		IF (@start_date IS NOT NULL AND @end_date IS NOT NULL AND @start_date!='' AND @end_date !='')
			Begin
				--Check Name And Email
				IF (@customer_name IS NOT NULL AND @customer_name !='' AND @customer_email IS NOT NULL AND @customer_email !='')
					BEGIN
						SELECT * FROM #Customer_Report_Table_TimeFilter 
						WHERE Lower(#Customer_Report_Table_TimeFilter.first_name + #Customer_Report_Table_TimeFilter.last_name) LIKE Lower('%'+ @customer_name +'%')
						AND Lower(#Customer_Report_Table_TimeFilter.email) LIKE Lower('%'+ @customer_email +'%')
						order by #Customer_Report_Table_TimeFilter.customer_id desc
		

					END
				-- Check Email
				ELSE IF (@customer_email IS NOT NULL AND @customer_email !='')
					BEGIN
						SELECT * FROM #Customer_Report_Table_TimeFilter 
						WHERE Lower(#Customer_Report_Table_TimeFilter.email) LIKE Lower('%'+ @customer_email +'%')
						order by #Customer_Report_Table_TimeFilter.customer_id desc
					
					END
				-- Check Name
				
				ELSE IF (@customer_name IS NOT NULL AND @customer_name !='')
					BEGIN
						SELECT * FROM #Customer_Report_Table_TimeFilter 
						WHERE Lower(#Customer_Report_Table_TimeFilter.first_name + #Customer_Report_Table_TimeFilter.last_name) LIKE Lower('%'+ @customer_name +'%')
						order by #Customer_Report_Table_TimeFilter.customer_id desc
					
					END
				-- No filter for name and email
				ELSE 
					BEGIN
						SELECT * FROM #Customer_Report_Table_TimeFilter 
						order by #Customer_Report_Table_TimeFilter.customer_id desc
					
					END 	
						
			End
		
		
		-- For Without Date Time
		ElSE
		
		Begin
				--Check Name And Email
				IF (@customer_name IS NOT NULL AND @customer_name !='' AND @customer_email IS NOT NULL AND @customer_email !='')
					BEGIN
						SELECT * FROM #Customer_Report_Table
						WHERE Lower(#Customer_Report_Table.first_name + #Customer_Report_Table.last_name) LIKE Lower('%'+ @customer_name +'%')
						AND Lower(#Customer_Report_Table.email) LIKE Lower('%'+ @customer_email +'%')
						order by #Customer_Report_Table.customer_id desc
		

					END
				-- Check Email
				ELSE IF (@customer_email IS NOT NULL AND @customer_email !='')
					BEGIN
						SELECT * FROM #Customer_Report_Table 
						WHERE Lower(#Customer_Report_Table.email) LIKE Lower('%'+ @customer_email +'%')
						order by #Customer_Report_Table.customer_id desc
					
					END
				-- Check Name
				
				ELSE IF (@customer_name IS NOT NULL AND @customer_name !='')
					BEGIN
						SELECT * FROM #Customer_Report_Table 
						WHERE Lower(#Customer_Report_Table.first_name + #Customer_Report_Table.last_name) LIKE Lower('%'+ @customer_name +'%')
						order by #Customer_Report_Table.customer_id desc
					
					END	
				ELSE 
					BEGIN
						SELECT * FROM #Customer_Report_Table 
						order by #Customer_Report_Table.customer_id desc
					
					END 			
    			End
    			
END

--Select * from customer_earned_winks where customer_earned_winks.customer_id =83

/*And CONVERT(CHAR(10),customer_earned_winks.created_at,111) 
BETWEEN CONVERT(CHAR(10),'2015-08-27',111) and CONVERT(CHAR(10),'2015-08-29',111)*/
