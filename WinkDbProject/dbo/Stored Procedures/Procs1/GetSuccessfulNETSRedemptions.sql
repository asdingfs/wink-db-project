CREATE PROCEDURE [dbo].[GetSuccessfulNETSRedemptions]
(@cronjob_date datetime)
AS
BEGIN
	IF(@cronjob_date = '' or @cronjob_date is null)
	BEGIN
		SET @cronjob_date = null;
	END

	SELECT c.first_name as firstName, c.email as email 
	FROM NETs_CANID_Redemption_Record_Detail as n,
	customer as c
	WHERE cast(n.cronjob_success_date as date) = cast(@cronjob_date as date)
	AND cast(n.updated_at as date) = cast(@cronjob_date as date)
	AND n.cronjob_status like 'done'
	AND n.customer_id = c.customer_id;

END

