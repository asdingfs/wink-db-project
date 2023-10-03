CREATE PROCEDURE [dbo].[Get_App_Maintenance_Status]
AS
BEGIN
	DECLARE @latestAction varchar(50);
	SELECT TOP(1) @latestAction = [action]
	FROM app_maintenance
	ORDER BY created_at desc

	IF(@latestAction like 'on')
	BEGIN
		SELECT '1' as response_code
		RETURN
	END
	ELSE
	BEGIN
		SELECT '0' as response_code
		RETURN
	END
END