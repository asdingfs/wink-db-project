Create PROCEDURE [dbo].[Get_ToUploadFile]

AS
BEGIN
	Select Top 1 * from mexkey order by mexkey.mex_id desc
END
