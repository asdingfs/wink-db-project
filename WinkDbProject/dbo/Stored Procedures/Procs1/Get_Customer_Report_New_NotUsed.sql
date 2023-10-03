CREATE PROCEDURE [dbo].[Get_Customer_Report_New_NotUsed]
	(@start_date datetime,
	 @end_date datetime)
AS
BEGIN
	IF (@start_date IS NOT NULL AND @end_date IS NOT NULL AND @start_date!='' AND @end_date !='')
	BEGIN
	SELECT customer.customer_id,customer.first_name,customer.last_name,
customer.email ,
(Select ISNULL(SUM(customer_earned_points.points),0) from customer_earned_points 
where customer_earned_points.customer_id = customer.customer_id
And CONVERT(CHAR(10),customer_earned_points.created_at,111) 
BETWEEN CONVERT(CHAR(10),@start_date,111) and CONVERT(CHAR(10),@end_date,111)

) As Total_QR_Scan_Points,
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


) As Total_Redeemed_eVouchers,
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

AS Redeemed_Points

From customer 
Group By customer.customer_id,customer.first_name,customer.last_name,
customer.email 
order by customer.customer_id desc

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

AS Redeemed_Points


From customer 
Group By customer.customer_id,customer.first_name,customer.last_name,
customer.email 
order by customer.customer_id desc


END


END

--Select * from customer_earned_winks where customer_earned_winks.customer_id =83

/*And CONVERT(CHAR(10),customer_earned_winks.created_at,111) 
BETWEEN CONVERT(CHAR(10),'2015-08-27',111) and CONVERT(CHAR(10),'2015-08-29',111)*/
