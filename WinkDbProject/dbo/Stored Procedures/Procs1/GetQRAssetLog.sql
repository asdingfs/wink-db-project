-- =============================================
CREATE PROCEDURE [dbo].[GetQRAssetLog]
(@action_id int)
AS
BEGIN
	Declare @action_type varchar(50)
	SET @action_type= (Select action_type from action_log where action_id =@action_id);

	IF(@action_type ='Edit')
	BEGIN
		SELECT a.*,o.*,n.*, m.qr_code_value 
		from action_log as a, qr_asset_olddata_log as o,qr_asset_newdata_log as n, asset_type_management as m
		where a.action_id = o.action_id 
		and n.action_id = a.action_id
		and a.action_id = @action_id
		and o.asset_type_management_id = m.asset_type_management_id
	END	
	ElSE
	BEGIN
		SELECT a.*,n.*, m.qr_code_value 
		FROM action_log as a, qr_asset_olddata_log as n, asset_type_management as m
		WHERE n.action_id = a.action_id
		AND a.action_id = @action_id
		and n.asset_type_management_id = m.asset_type_management_id
	END
END

