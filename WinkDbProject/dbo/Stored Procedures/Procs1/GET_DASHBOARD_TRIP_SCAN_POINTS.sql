

CREATE PROC [dbo].[GET_DASHBOARD_TRIP_SCAN_POINTS]

AS

BEGIN

	SELECT (SELECT SUM(points) FROM customer_earned_points) AS scan_points, 
	(
		(
			SELECT SUM(total_points) 
			FROM wink_canid_earned_points
			WHERE CAST(business_date AS DATE) <= '2022-05-23'
			AND CAST(business_date AS DATE) != '2022-05-19'
			AND [source] like 'trip'
		)
		+
		CAST(
		(
			SELECT SUM(total_points)
			FROM wink_net_canid_earned_points
			WHERE card_type like '10'
		) AS INT)
	)  AS trip_points
	
END