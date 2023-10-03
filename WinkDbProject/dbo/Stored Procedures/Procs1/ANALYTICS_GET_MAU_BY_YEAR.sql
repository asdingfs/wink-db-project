CREATE PROC [dbo].[ANALYTICS_GET_MAU_BY_YEAR]
@year int,
@date varchar(20)

AS

BEGIN

	declare @today date = cast((select * from VW_CURRENT_SG_TIME) as date)
	declare @current_month varchar(10) = LEFT(CONVERT(VARCHAR(10),@today, 126), 7)
	--declare @end_date_of_current_month date = EOMONTH(cast(@current_month+'-01' as date))

	declare @new_customer int
	declare @locked int

	IF (@date = @current_month)
	BEGIN
		set @new_customer =
		(
			select count(distinct customer_id) from customer 
			where LEFT(CONVERT(VARCHAR(10), created_at, 126), 7) = @date and group_id in (13,14)
		)

		set @locked = 
		(
			select count(distinct customer_id)*(-1) as locked_account from customer 
			where group_id in (13,14) and status = 'disable'		
		)
	END
	ELSE
	BEGIN
		SET @new_customer =
		(
			SELECT new_customer FROM Cohort_MAU_Chart where period = @date
		)

		SET @locked =
		(
			SELECT locked_todate_current_month*(-1) FROM Cohort_MAU_Chart where period = @date
		)
	END

	SELECT period, @new_customer as new_customer,churned*(-1) as churned,resurrected,retention,quick_ratio,active_user as all_active_user,@locked as locked_account
	FROM Cohort_MAU_Chart
	WHERE year = @year AND period = @date
	RETURN;
END	
