CREATE Procedure [dbo].[GetWinkGateAssetById]
(   @winkGateId int
)
AS
BEGIN
	SELECT [id]
      ,[gate_id]
      ,[description]
      ,[latitude]
      ,[longitude]
      ,[range]
	FROM [winkwink].[dbo].[wink_gate_asset]
	WHERE id = @winkGateId;
END