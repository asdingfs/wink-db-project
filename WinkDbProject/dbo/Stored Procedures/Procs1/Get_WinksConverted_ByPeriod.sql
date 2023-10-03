CREATE PROCEDURE [dbo].[Get_WinksConverted_ByPeriod]
	(
	 @from_date datetime,
	 @to_date datetime,
	 @category varchar(50) = NULL,
	 @year varchar(10) = NULL
	  
	)
AS
BEGIN
	
	   IF (@category = NULL)  -- to compatible with old scripts.
	   BEGIN
	   		SELECT  SUM(isnull(customer_earned_winks.total_winks,0))as converted_winks ,
			CAST(customer_earned_winks.created_at As Date) As period
			from customer_earned_winks
			WHERE CAST(customer_earned_winks.created_at As Date) BETWEEN @from_date AND @to_date
			GROUP BY CAST(customer_earned_winks.created_at As Date)
			RETURN
		END
	   IF (@category !='year_to_month' and (@year ='' or @year is null))
	   BEGIN
		SELECT  SUM(isnull(customer_earned_winks.total_winks,0))as converted_winks ,
		CAST(customer_earned_winks.created_at As Date) As period
		from customer_earned_winks
		WHERE CAST(customer_earned_winks.created_at As Date) BETWEEN @from_date AND @to_date
		GROUP BY CAST(customer_earned_winks.created_at As Date)
		END
		ELSE IF (@category ='year_to_month' and (@year ='' or @year is null))
		BEGIN

		
           SELECT SUM(isnull(customer_earned_winks.total_winks,0))as converted_winks, 
		   RIGHT('0'+ CONVERT(VARCHAR(2), Month(created_at)), 2) + '-' + CAST(YEAR(created_at) AS VARCHAR(4)) AS period 
		   FROM customer_earned_winks 
		    WHERE  CAST(created_at As Date) >= CAST (@from_date AS Date) and CAST(created_at As Date) <= CAST (@to_date AS Date)
			GROUP BY RIGHT('0'+ CONVERT(VARCHAR(2), Month(created_at)), 2) + '-' + CAST(YEAR(created_at) AS VARCHAR(4))
			Order by RIGHT('0'+ CONVERT(VARCHAR(2), Month(created_at)), 2) + '-' + CAST(YEAR(created_at) AS VARCHAR(4))

		END
		ELSE IF ((@category ='' OR @category is null) and  @year !='' and @year is not null)
		BEGIN
		print('fggg')
		
           SELECT SUM(isnull(customer_earned_winks.total_winks,0))as converted_winks, 
		   RIGHT('0'+ CONVERT(VARCHAR(2), Month(created_at)), 2) + '-' + CAST(YEAR(created_at) AS VARCHAR(4)) AS period 
		   FROM customer_earned_winks 
		    WHERE  --CAST(created_at As Date) >= CAST (@from_date AS Date) and CAST(created_at As Date) <= CAST (@to_date AS Date)
			--and 
			Year(CAST(created_at As Date))=@year
			GROUP BY RIGHT('0'+ CONVERT(VARCHAR(2), Month(created_at)), 2) + '-' + CAST(YEAR(created_at) AS VARCHAR(4))

			Order by RIGHT('0'+ CONVERT(VARCHAR(2), Month(created_at)), 2) + '-' + CAST(YEAR(created_at) AS VARCHAR(4))

		END
END
