CREATE  PROCEDURE [dbo].[Get_QR_Code_Scan_Report_bak]
	(@start_date datetime,
	 @end_date datetime)
AS
BEGIN
IF (@start_date IS NOT NULL AND @end_date IS NOT NULL AND @start_date!='' AND @end_date!='')
BEGIN

    
	Select Count(*)As total_scan ,customer_earned_points.qr_code from customer_earned_points
	
	Where  CAST(customer_earned_points.created_at as Date) BETWEEN @start_date AND @end_date
	
	Group by customer_earned_points.qr_code
     
	

END
	ELSE
	
		BEGIN
			Select Count(*)As total_scan ,customer_earned_points.qr_code from customer_earned_points
	
			--Where  CAST(customer_earned_points.created_at as Date) BETWEEN @start_date AND @end_date
	
			Group by customer_earned_points.qr_code
		
		END
END