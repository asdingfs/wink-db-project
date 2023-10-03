CREATE PROCEDURE [dbo].[Get_QRNormalisationLog_By_ActionId]
(
	@action_id int
)
AS
BEGIN
	Declare @action_type varchar(50)
	SET @action_type= (Select action_type from action_log where action_id =@action_id);

	IF(@action_type ='Normalisation')
	Begin
		select * from action_log as a,duplicate_normalisation_log as d
		where a.action_id = d.action_id 
		and a.action_id = @action_id
	End
END

