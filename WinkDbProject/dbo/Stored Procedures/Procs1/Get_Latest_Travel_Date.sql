
CREATE PROCEDURE [dbo].[Get_Latest_Travel_Date]
AS
BEGIN
	SELECT TOP(1) T.business_date 
	FROM (
		SELECT TOP(1) business_date as business_date
		FROM wink_canid_earned_points
		ORDER by business_date desc
		UNION
		SELECT TOP(1) created_at as business_date
		FROM spg_earned_points
		ORDER by created_at desc
	) as T 
	ORDER BY T.business_date desc
END

