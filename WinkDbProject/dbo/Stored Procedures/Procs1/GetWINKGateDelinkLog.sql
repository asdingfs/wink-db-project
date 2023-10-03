-- =============================================
CREATE PROCEDURE [dbo].[GetWINKGateDelinkLog]
(@action_id int)
AS
BEGIN
	Declare @action_type varchar(50)
	SET @action_type= (Select action_type from action_log where action_id =@action_id);

	IF(@action_type ='Delink')
	BEGIN
		SELECT * 
		from action_log as a, gate_booking_delink_data_log as d
		where a.action_id = d.action_id 
		and a.action_id = @action_id
	END	
	
END

