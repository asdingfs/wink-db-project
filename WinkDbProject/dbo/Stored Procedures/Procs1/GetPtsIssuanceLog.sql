-- =============================================
CREATE PROCEDURE [dbo].[GetPtsIssuanceLog]
(@action_id int)
AS
BEGIN
	Declare @action_type varchar(50)
	SET @action_type= (Select action_type from action_log where action_id =@action_id);

	--IF(@action_type ='Add Users')
	--BEGIN
		SELECT * 
		FROM action_log as a, pts_issuance_data_log as n
		WHERE n.action_id = a.action_id
		AND a.action_id = @action_id
	--END	
END

