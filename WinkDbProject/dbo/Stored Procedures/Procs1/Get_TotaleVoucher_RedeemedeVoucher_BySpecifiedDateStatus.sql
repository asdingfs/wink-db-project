CREATE PROCEDURE [dbo].[Get_TotaleVoucher_RedeemedeVoucher_BySpecifiedDateStatus]
	(@status varchar(50))
AS
BEGIN
DECLARE @filer_date datetime 
EXEC GET_CURRENT_SINGAPORT_DATETIME @filer_date OUTPUT
		-- Filte By Today
		IF (@status = 'today')
		BEGIN
		  SET @filer_date = CAST(@filer_date as Date)
		 
		END
		ELSE IF (@status ='y') -- Filter By Yesterday
			BEGIN
					SET @filer_date = dateadd(day,-1, cast(@filer_date as date))
					
			END
			


IF OBJECT_ID('tempdb..#eVoucher_table') IS NOT NULL DROP TABLE #eVoucher_table

CREATE TABLE #eVoucher_table
(
 total_evouchers int not null default 0 ,
 redeemed_evouchers int not null default 0 ,
 period int 
)


IF OBJECT_ID('tempdb..#redeemed_eVoucher_table') IS NOT NULL DROP TABLE #redeemed_eVoucher_table

CREATE TABLE #redeemed_eVoucher_table
(
 total_evouchers int not null default 0 ,
 redeemed_evouchers int not null default 0 ,
 period int
)

-- Total eVouchers
	INSERT INTO #eVoucher_table (total_evouchers,period)
	SELECT COUNT(*),datepart(HOUR,customer_earned_evouchers.created_at) as period
	from customer_earned_evouchers
	WHERE  CAST(customer_earned_evouchers.created_at As Date) = CAST (@filer_date AS Date)
	GROUP BY datepart(HOUR,customer_earned_evouchers.created_at)

	-- Total Redeemed eVouchers
	INSERT INTO #redeemed_eVoucher_table (redeemed_evouchers,period)
	SELECT COUNT(*),datepart(HOUR,eVoucher_transaction.created_at) as period FROM eVoucher_transaction
	WHERE  CAST(eVoucher_transaction.created_at As Date) = CAST (@filer_date AS Date)
	GROUP BY datepart(HOUR,eVoucher_transaction.created_at)
	
	IF OBJECT_ID('tempdb..#eVoucher_table2') IS NOT NULL DROP TABLE #eVoucher_table2

	CREATE TABLE #eVoucher_table2
	(
	total_evouchers int not null default 0 ,
	redeemed_evouchers int not null default 0 ,
	period int 
	)
	INSERT INTO #eVoucher_table2 (total_evouchers,redeemed_evouchers,period)
	SELECT #eVoucher_table.total_evouchers,#eVoucher_table.redeemed_evouchers,#eVoucher_table.period
	FROM #eVoucher_table
	UNION
	SELECT #redeemed_eVoucher_table.total_evouchers,#redeemed_eVoucher_table.redeemed_evouchers,#redeemed_eVoucher_table.period
	FROM #redeemed_eVoucher_table
	
	SELECT SUM(ISNULL(#eVoucher_table2.total_evouchers,0)) AS total_evouchers,
	SUM(ISNULL(#eVoucher_table2.redeemed_evouchers,0)) AS redeemed_evouchers,
	#eVoucher_table2.period
	
	FROM #eVoucher_table2
	
	GROUP BY
	#eVoucher_table2.period
	

	/*SELECT COUNT(*),CAST(customer_earned_evouchers.created_at as DATE)
	from customer_earned_evouchers
	WHERE  CAST(customer_earned_evouchers.created_at As Date) Between 
	CAST(@start_date As Date)AND 
	CAST(@end_date As Date)
	AND customer_earned_evouchers.used_status =1
	GROUP BY CAST(customer_earned_evouchers.created_at as DATE)
	IF EXISTS (SELECT * FROM #redeemed_eVoucher_table)
		BEGIN
		Select #eVoucher_table.total_evouchers,#eVoucher_table.created_at,
		#redeemed_eVoucher_table.redeemed_evouchers
		
		from #eVoucher_table,#redeemed_eVoucher_table
		WHERE CAST(#eVoucher_table.created_at As Date) = CAST(#redeemed_eVoucher_table.created_at As Date)
		
		RETURN
		
		END 
	ELSE 
		BEGIN
			SELECT * FROM #eVoucher_table
			RETURN
		
		END*/
	


 
 
 
/*from customer_earned_evouchers 

WHERE  CAST(customer_earned_evouchers.created_at as Date)>= CAST(@start_date  as DATE)
AND CAST(customer_earned_evouchers.created_at as DATE) <= CAST(@end_date as DATE)
GROUP BY customer_earned_evouchers.created_at*/
--Select * from #eVoucher_table

END

--Select * from customer_earned_evouchers order by earned_evoucher_id desc
