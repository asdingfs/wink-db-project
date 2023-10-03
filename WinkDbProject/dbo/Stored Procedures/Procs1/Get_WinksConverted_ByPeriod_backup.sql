CREATE PROCEDURE [dbo].[Get_WinksConverted_ByPeriod_backup]
	(
	 @from_date datetime,
	 @to_date datetime
	  
	)
AS
BEGIN
	
		SELECT  SUM(isnull(customer_earned_winks.total_winks,0))as converted_winks ,
		CAST(customer_earned_winks.created_at As Date) As period
		from customer_earned_winks
		WHERE CAST(customer_earned_winks.created_at As Date) BETWEEN @from_date AND @to_date
		GROUP BY CAST(customer_earned_winks.created_at As Date)
END
