-- =============================================
CREATE PROCEDURE [dbo].[Get_CIC_Staff_DetailLog_By_ActionId]
	(@action_id int)
AS
BEGIN
Declare @action_type varchar(50)

SET @action_type= (Select action_type from cic_action_log where action_id =@action_id)
print (@action_type)
IF(@action_type ='Edit')
   Begin
	select * from cic_action_log as a,thirdparty_staff_new_data as o,thirdparty_staff_old_data as n
	where a.action_id = o.action_id 
	and n.action_id = a.action_id
	and a.action_id = @action_id
	
	End
	
ElSE
	Begin
	
	select * from cic_action_log as a,thirdparty_staff_old_data as n
	where 
	 n.action_id = a.action_id
	 and a.action_id = @action_id
	
	End
	
END

