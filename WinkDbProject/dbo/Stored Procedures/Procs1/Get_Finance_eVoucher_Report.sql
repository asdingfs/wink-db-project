CREATE PROCEDURE [dbo].[Get_Finance_eVoucher_Report]
	(@year varchar(10),
	 @expired_status varchar(10),
	 @used_status varchar(10)
	)
AS
BEGIN
Declare @selected_year int 
set @selected_year = @year

Declare @current_date datetime

Exec GET_CURRENT_SINGAPORT_DATETIME @current_date output 

IF(@used_status ='Yes')
BEGIN
SELECT DATEPART(Year, t.created_at) Year, DATEPART(Month, t.created_at) Month, SUM(t.eVoucher_amount) as total_amount
--SUM(redeemed_winks) as total_redeemed_winks
FROM eVoucher_transaction as t 
--, customer_earned_evouchers as e
where 

--t.eVoucher_id = e.earned_evoucher_id

--AND e.used_status = 1

--AND
(
(
(DATEPART(Month, t.created_at) = 1 OR 
DATEPART(Month, t.created_at) = 2 OR
DATEPART(Month, t.created_at) = 3 OR
DATEPART(Month, t.created_at) = 4 ) 

AND

(DATEPART(Year, t.created_at) = (@selected_year+1))


) OR

( 
(DATEPART(Month, t.created_at) = 5 OR 
DATEPART(Month, t.created_at) = 6 OR
DATEPART(Month, t.created_at) = 7 OR
DATEPART(Month, t.created_at) = 8 OR

DATEPART(Month, t.created_at) = 9 OR

DATEPART(Month, t.created_at) = 10 OR

DATEPART(Month, t.created_at) = 11 OR

DATEPART(Month, t.created_at) = 12 )
 AND
(DATEPART(Year, t.created_at) = @selected_year)
)
)

GROUP BY DATEPART(Year, t.created_at), DATEPART(Month, t.created_at)
RETURN
END
ELSE IF(@expired_status ='Yes')
BEGIN
SELECT DATEPART(Year, expired_date) Year, DATEPART(Month, expired_date) Month, SUM(eVoucher_amount) as total_amount,
SUM(redeemed_winks) as total_redeemed_winks
FROM customer_earned_evouchers
where 
(
(DATEPART(Month, expired_date) = 1 OR 
DATEPART(Month, expired_date) = 2 OR
DATEPART(Month, expired_date) = 3 OR
DATEPART(Month, expired_date) = 4 ) 

AND

(DATEPART(Year, expired_date) = (@selected_year+1))

and CAST (expired_date as date) <= CAST (@current_date as date)
and used_status =0 

) OR

( 
(DATEPART(Month, expired_date) = 5 OR 
DATEPART(Month, expired_date) = 6 OR
DATEPART(Month, expired_date) = 7 OR
DATEPART(Month, expired_date) = 8 OR

DATEPART(Month, expired_date) = 9 OR

DATEPART(Month, expired_date) = 10 OR

DATEPART(Month, expired_date) = 11 OR

DATEPART(Month, expired_date) = 12 )
 AND
(DATEPART(Year, expired_date) = @selected_year)


and CAST (expired_date as date) <= CAST (@current_date as date)
and used_status =0


)



GROUP BY DATEPART(Year, expired_date), DATEPART(Month, expired_date)


RETURN
END

ELSE

BEGIN

SELECT DATEPART(Year, created_at) Year, DATEPART(Month, created_at) Month, SUM(eVoucher_amount) as total_amount,
SUM(redeemed_winks) as total_redeemed_winks
FROM customer_earned_evouchers
where 
(
(DATEPART(Month, created_at) = 1 OR 
DATEPART(Month, created_at) = 2 OR
DATEPART(Month, created_at) = 3 OR
DATEPART(Month, created_at) = 4 ) 

AND

(DATEPART(Year, created_at) = (@selected_year+1))


) OR

( 
(DATEPART(Month, created_at) = 5 OR 
DATEPART(Month, created_at) = 6 OR
DATEPART(Month, created_at) = 7 OR
DATEPART(Month, created_at) = 8 OR

DATEPART(Month, created_at) = 9 OR

DATEPART(Month, created_at) = 10 OR

DATEPART(Month, created_at) = 11 OR

DATEPART(Month, created_at) = 12 )
 AND
(DATEPART(Year, created_at) = @selected_year)
)

GROUP BY DATEPART(Year, created_at), DATEPART(Month, created_at)
RETURN

END
END

