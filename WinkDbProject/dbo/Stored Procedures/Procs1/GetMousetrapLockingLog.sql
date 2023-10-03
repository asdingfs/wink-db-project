-- =============================================
CREATE PROCEDURE [dbo].[GetMousetrapLockingLog]
(@action_id int)
AS
BEGIN
	Declare @action_type varchar(50)
	SET @action_type= (Select action_type from action_log where action_id =@action_id);

	IF(@action_type ='IP(/32)')
	BEGIN
		SELECT * 
		FROM action_log as a, lock_ip32_log as l
		WHERE l.action_id = a.action_id
		AND a.action_id = @action_id
	END	
	ElSE IF(@action_type ='IP(/16)')
	BEGIN
		SELECT * 
		FROM action_log as a, lock_ip16_log as l
		WHERE l.action_id = a.action_id
		AND a.action_id = @action_id
	END
	ElSE IF(@action_type ='Unlock')
	BEGIN
		SELECT * 
		FROM action_log as a, unlock_ip_log as l
		WHERE l.action_id = a.action_id
		AND a.action_id = @action_id
	END
END

