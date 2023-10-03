-- =============================================
CREATE PROCEDURE [dbo].[GetWINKGateBookingLog]
(@action_id int)
AS
BEGIN
	Declare @action_type varchar(50)
	SET @action_type= (Select action_type from action_log where action_id =@action_id);

	IF(@action_type ='Edit')
	BEGIN
		SELECT * 
		from action_log as a, gate_booking_old_data_log as o, gate_booking_new_data_log as n
		where a.action_id = o.action_id 
		and n.action_id = a.action_id
		and a.action_id = @action_id
	END	
	ElSE
	BEGIN
		SELECT * 
		FROM action_log as a, gate_booking_old_data_log as n
		WHERE n.action_id = a.action_id
		AND a.action_id = @action_id
	END
END

