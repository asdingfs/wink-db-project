CREATE PROCEDURE [dbo].[Get_Customer_Report_bak03122015]
	(@start_date datetime,
	 @end_date datetime,
	 @customer_name varchar(150),
	 @customer_email varchar(150))
AS
BEGIN
--new add
DECLARE @CURRENT_DATETIME datetimeoffset = switchoffset (CONVERT(datetimeoffset, GETDATE()), '+08:00');


	IF (@start_date IS NOT NULL AND @end_date IS NOT NULL AND @start_date!='' AND @end_date !='')
	BEGIN	
		IF (@customer_name IS NOT NULL AND @customer_name  != '')
		BEGIN
		IF (@customer_email IS NOT NULL AND @customer_email != '') 

			BEGIN

			


					SELECT * FROM (SELECT customer.customer_id,customer.first_name,customer.last_name,
					customer.email ,
					(Select ISNULL(SUM(customer_earned_points.points),0) from customer_earned_points 
					 where customer_earned_points.customer_id = customer.customer_id
					 And CONVERT(CHAR(10),customer_earned_points.created_at,111) 
					 BETWEEN CONVERT(CHAR(10),@start_date,111) and CONVERT(CHAR(10),@end_date,111)

					) As Total_QR_Scan_Points,
		
		
		--new add start

		/*	(SELECT Count(*)  FROM  (
  
 SELECT customer_earned_evouchers.earned_evoucher_id FROM  customer_earned_evouchers
 WHERE  (DATEDIFF(SECOND,CAST(@CURRENT_DATETIME As datetime),CAST(customer_earned_evouchers.expired_date As datetime))) < 0
  
 EXCEPT SELECT eVoucher_transaction.eVoucher_id FROM  eVoucher_transaction,customer_earned_evouchers WHERE eVoucher_transaction.customer_id = customer_earned_evouchers.customer_id ) AS tbltemp) AS Expired_Evoucher,
 
 --new add end*/
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
					select SUM(wink_canid_earned_points.total_points) As trip_points from can_id ,wink_canid_earned_points
					where can_id.customer_canid = wink_canid_earned_points.can_id
					AND CAST (wink_canid_earned_points.created_at AS Date ) 
					BETWEEN CAST (@start_date AS date)  and CAST (@end_date AS date) 
					and can_id.customer_id = customer.customer_id 

					)
					As Trip_Points

					From customer
	
					Group By customer.customer_id,customer.first_name,customer.last_name,
					customer.email 
		
		
					) as tbltemp

					WHERE Lower(tbltemp.first_name + tbltemp.last_name) LIKE Lower('%'+ @customer_name +'%')
					AND Lower(tbltemp.email) LIKE Lower('%'+ @customer_email +'%')
					order by tbltemp.customer_id desc

			END
		ELSE
			BEGIN
					SELECT * FROM (SELECT customer.customer_id,customer.first_name,customer.last_name,
					customer.email ,
						(Select ISNULL(SUM(customer_earned_points.points),0) from customer_earned_points 
						 where customer_earned_points.customer_id = customer.customer_id
						 And CONVERT(CHAR(10),customer_earned_points.created_at,111) 
						 BETWEEN CONVERT(CHAR(10),@start_date,111) and CONVERT(CHAR(10),@end_date,111)

						) As Total_QR_Scan_Points,
		

		--new add start

			/*(SELECT Count(*)  FROM  (
  
 SELECT customer_earned_evouchers.earned_evoucher_id FROM  customer_earned_evouchers
 WHERE  (DATEDIFF(SECOND,CAST(@CURRENT_DATETIME As datetime),CAST(customer_earned_evouchers.expired_date As datetime))) < 0
  
 EXCEPT SELECT eVoucher_transaction.eVoucher_id FROM  eVoucher_transaction,customer_earned_evouchers WHERE eVoucher_transaction.customer_id = customer_earned_evouchers.customer_id ) AS tbltemp) AS Expired_Evoucher,
 */
 --new add end
 
 (select COUNT(*) from customer_earned_evouchers 
					where customer_earned_evouchers.customer_id = customer.customer_id
					AND customer_earned_evouchers.used_status = 0
					--AND CAST(customer_earned_evouchers.created_at AS DATE) BETWEEN @start_date AND @end_date
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
						select SUM(wink_canid_earned_points.total_points) As trip_points from can_id ,wink_canid_earned_points
						where can_id.customer_canid = wink_canid_earned_points.can_id
						AND CAST (wink_canid_earned_points.created_at AS Date ) 
						BETWEEN CAST (@start_date AS date)  and CAST (@end_date AS date) 
						and can_id.customer_id = customer.customer_id 

						)
						As Trip_Points

						From customer
	
						Group By customer.customer_id,customer.first_name,customer.last_name,
						customer.email 
		
		
						) as tbltemp

						WHERE Lower(tbltemp.first_name + tbltemp.last_name) LIKE Lower('%'+ @customer_name +'%')
						order by tbltemp.customer_id desc
		

			END

		END
		ELSE IF(@customer_email IS NOT NULL AND @customer_email != '')
		BEGIN
					SELECT * FROM (SELECT customer.customer_id,customer.first_name,customer.last_name,
					customer.email ,
					(Select ISNULL(SUM(customer_earned_points.points),0) from customer_earned_points 
					 where customer_earned_points.customer_id = customer.customer_id
					 And CONVERT(CHAR(10),customer_earned_points.created_at,111) 
					 BETWEEN CONVERT(CHAR(10),@start_date,111) and CONVERT(CHAR(10),@end_date,111)

					) As Total_QR_Scan_Points,
		

		--new add start

			(SELECT Count(*)  FROM  (
  
 SELECT customer_earned_evouchers.earned_evoucher_id FROM  customer_earned_evouchers
 WHERE  (DATEDIFF(SECOND,CAST(@CURRENT_DATETIME As datetime),CAST(customer_earned_evouchers.expired_date As datetime))) < 0
  
 EXCEPT SELECT eVoucher_transaction.eVoucher_id FROM  eVoucher_transaction,customer_earned_evouchers WHERE eVoucher_transaction.customer_id = customer_earned_evouchers.customer_id ) AS tbltemp) AS Expired_Evoucher,
 
 --new add end

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
					select SUM(wink_canid_earned_points.total_points) As trip_points from can_id ,wink_canid_earned_points
					where can_id.customer_canid = wink_canid_earned_points.can_id
					AND CAST (wink_canid_earned_points.created_at AS Date ) 
					BETWEEN CAST (@start_date AS date)  and CAST (@end_date AS date) 
					and can_id.customer_id = customer.customer_id 

					)
					As Trip_Points

					From customer
	
					Group By customer.customer_id,customer.first_name,customer.last_name,
					customer.email 
		
		
					) as tbltemp

					WHERE Lower(tbltemp.email) LIKE Lower('%'+ @customer_email +'%')
					
					order by tbltemp.customer_id desc

		END
	
	ELSE
	BEGIN

	SELECT customer.customer_id,customer.first_name,customer.last_name,
	customer.email ,
		(Select ISNULL(SUM(customer_earned_points.points),0) from customer_earned_points 
		 where customer_earned_points.customer_id = customer.customer_id
		 And CONVERT(CHAR(10),customer_earned_points.created_at,111) 
		 BETWEEN CONVERT(CHAR(10),@start_date,111) and CONVERT(CHAR(10),@end_date,111)

		) As Total_QR_Scan_Points,
		
		--new add start

			(SELECT Count(*)  FROM  (
  
 SELECT customer_earned_evouchers.earned_evoucher_id FROM  customer_earned_evouchers
 WHERE  (DATEDIFF(SECOND,CAST(@CURRENT_DATETIME As datetime),CAST(customer_earned_evouchers.expired_date As datetime))) < 0
  
 EXCEPT SELECT eVoucher_transaction.eVoucher_id FROM  eVoucher_transaction,customer_earned_evouchers WHERE eVoucher_transaction.customer_id = customer_earned_evouchers.customer_id ) AS tbltemp) AS Expired_Evoucher,
 
 --new add end
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
		select SUM(wink_canid_earned_points.total_points) As trip_points from can_id ,wink_canid_earned_points
		where can_id.customer_canid = wink_canid_earned_points.can_id
		AND CAST (wink_canid_earned_points.created_at AS Date ) 
		BETWEEN CAST (@start_date AS date)  and CAST (@end_date AS date) 
		and can_id.customer_id = customer.customer_id 

		)
		As Trip_Points

		From customer
	
		Group By customer.customer_id,customer.first_name,customer.last_name,
		customer.email 
		order by customer.customer_id desc
	END	
		
END 


ELSE
	BEGIN
	SELECT customer.customer_id,customer.first_name,customer.last_name,
	customer.email ,
	(Select ISNULL(SUM(customer_earned_points.points),0) from customer_earned_points 
	 where customer_earned_points.customer_id = customer.customer_id
	--And CONVERT(CHAR(10),customer_earned_points.created_at,111) 
	--BETWEEN CONVERT(CHAR(10),@start_date,111) and CONVERT(CHAR(10),@end_date,111)

	) As Total_QR_Scan_Points,

	/*--zw add start

			(SELECT Count(*)  FROM  (
  
 SELECT customer_earned_evouchers.earned_evoucher_id FROM  customer_earned_evouchers
 WHERE  (DATEDIFF(SECOND,CAST(@CURRENT_DATETIME As datetime),CAST(customer_earned_evouchers.expired_date As datetime))) < 0
  
 EXCEPT SELECT eVoucher_transaction.eVoucher_id FROM  eVoucher_transaction,customer_earned_evouchers WHERE eVoucher_transaction.customer_id = customer_earned_evouchers.customer_id ) AS tbltemp) AS Expired_Evoucher,
 
 --zw add end*/
 
     (select COUNT(*) from customer_earned_evouchers 
					where customer_earned_evouchers.customer_id = customer.customer_id
					AND customer_earned_evouchers.used_status = 0
					--AND CAST(customer_earned_evouchers.created_at AS DATE) BETWEEN @start_date AND @end_date
					AND CAST (customer_earned_evouchers.expired_date AS Date) < CAST (@CURRENT_DATETIME AS Date)

					)
					AS Expired_Evoucher,
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
		select SUM(wink_canid_earned_points.total_points) As trip_points from can_id ,wink_canid_earned_points
		where can_id.customer_canid = wink_canid_earned_points.can_id
		and can_id.customer_id = customer.customer_id 

	)
	As Trip_Points



From customer 
Group By customer.customer_id,customer.first_name,customer.last_name,
customer.email order by customer.customer_id desc


END


END

--Select * from customer_earned_winks where customer_earned_winks.customer_id =83

/*And CONVERT(CHAR(10),customer_earned_winks.created_at,111) 
BETWEEN CONVERT(CHAR(10),'2015-08-27',111) and CONVERT(CHAR(10),'2015-08-29',111)*/
