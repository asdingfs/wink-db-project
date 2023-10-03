CREATE PROCEDURE [dbo].[Get_AppMaintenanceLog_By_ActionId]
(
	@action_id int
)
AS
BEGIN
	Declare @action_object varchar(150)
	SET @action_object= (Select action_object from action_log where action_id =@action_id);

	IF(@action_object like 'App Maintenance')
	Begin
		select * from action_log as a,app_maintenance_log as d
		where a.action_id = d.action_id 
		and a.action_id = @action_id
	End
END

