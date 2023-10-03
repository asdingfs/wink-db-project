CREATE PROCEDURE [dbo].[Get_WinksConverted_BySpecifiedDateStatus]
	(
	 @status varchar(25))
AS
BEGIN
DECLARE @filter_date datetime 
DECLARE @filter_by_hour int
DECLARE @from_date datetime
DECLARE @to_date datetime
DECLARE @date_diff int
EXEC GET_CURRENT_SINGAPORT_DATETIME @filter_date OUTPUT
		-- Filte By Today
		IF (@status = 'today')
		BEGIN
		  SET @filter_date = CAST(@filter_date as Date)
		  SET @filter_by_hour =1
		END
		ELSE IF (@status ='y')
			BEGIN
					SET @filter_date = dateadd(day,-1, cast(@filter_date as date))
					SET @filter_by_hour =1
			END
			
				-- Check Filter By Hour or Date
				IF(@filter_by_hour=1)
					BEGIN
				
				SELECT  SUM(isnull(customer_earned_winks.total_winks,0))as converted_winks ,
				datepart(HOUR,customer_earned_winks.created_at) as period
				from customer_earned_winks
				WHERE CAST(customer_earned_winks.created_at As Date) = @filter_date
				GROUP BY datepart(HOUR,customer_earned_winks.created_at)
					END
				ELSE
					BEGIN
						IF @status ='week_to_date'
							SET @date_diff = datepart(dw,cast(@filter_date as date))
							print ('@date_diff')
							print (@date_diff)
							SET @from_date = dateadd(day,-@date_diff+1, cast(@filter_date as date))
							print ('@from_date')
							print (@from_date)
							SET @to_date = @filter_date
							SELECT  SUM(isnull(customer_earned_winks.total_winks,0))as converted_winks ,
							CAST(customer_earned_winks.created_at As Date) As period
							from customer_earned_winks
							WHERE CAST(customer_earned_winks.created_at As Date) BETWEEN @from_date AND @to_date
							GROUP BY CAST(customer_earned_winks.created_at As Date)
										
					END
					
			

END
--select * from customer_earned_winks

SET @date_diff = datepart(dw,getdate())
SELECT datepart(dw,getdate())
SELECT dateadd(day,-4+1, cast(getdate() as date))
