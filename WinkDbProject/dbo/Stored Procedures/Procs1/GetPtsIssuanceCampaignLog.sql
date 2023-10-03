-- =============================================
CREATE PROCEDURE [dbo].[GetPtsIssuanceCampaignLog]
(@action_id int)
AS
BEGIN
	Declare @action_type varchar(50)
	SET @action_type= (Select action_type from action_log where action_id =@action_id);

	IF(@action_type ='New')
	BEGIN
		SELECT * 
		FROM action_log as a, pts_issuance_campaign_old_data_log as n
		WHERE n.action_id = a.action_id
		AND a.action_id = @action_id
	END	
END

