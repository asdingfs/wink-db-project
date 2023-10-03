CREATE PROCEDURE [dbo].[Get_TotaleVoucher_RedeemedeVoucher_ByPeriod]
	(@from_date datetime,
	 @to_date datetime
	  )
AS
BEGIN
DECLARE @filer_date datetime 
EXEC GET_CURRENT_SINGAPORT_DATETIME @filer_date OUTPUT	


IF OBJECT_ID('tempdb..#eVoucher_table') IS NOT NULL DROP TABLE #eVoucher_table

CREATE TABLE #eVoucher_table
(
 total_evouchers int not null default 0 ,
 redeemed_evouchers int not null default 0 ,
 period datetime 
)


IF OBJECT_ID('tempdb..#redeemed_eVoucher_table') IS NOT NULL DROP TABLE #redeemed_eVoucher_table

CREATE TABLE #redeemed_eVoucher_table
(
 total_evouchers int not null default 0 ,
 redeemed_evouchers int not null default 0 ,
 period datetime
)

-- Total eVouchers
	INSERT INTO #eVoucher_table (total_evouchers,period)
	SELECT COUNT(*),CAST(customer_earned_evouchers.created_at As Date) as period
	from customer_earned_evouchers
	WHERE  CAST(customer_earned_evouchers.created_at As Date) BETWEEN CAST(@from_date AS Date)
	 AND CAST(@to_date AS Date)
	GROUP BY CAST(customer_earned_evouchers.created_at As Date)

	-- Total Redeemed eVouchers
	INSERT INTO #redeemed_eVoucher_table (redeemed_evouchers,period)
	SELECT COUNT(*),CAST(eVoucher_transaction.created_at AS Date) as period FROM eVoucher_transaction
	WHERE  CAST(eVoucher_transaction.created_at As Date)  BETWEEN CAST(@from_date AS Date)
	 AND CAST(@to_date AS Date)
	GROUP BY CAST(eVoucher_transaction.created_at AS Date)
	
	IF OBJECT_ID('tempdb..#eVoucher_table2') IS NOT NULL DROP TABLE #eVoucher_table2

	CREATE TABLE #eVoucher_table2
	(
	total_evouchers int not null default 0 ,
	redeemed_evouchers int not null default 0 ,
	period datetime 
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
	
END

--Select * from customer_earned_evouchers order by earned_evoucher_id desc
