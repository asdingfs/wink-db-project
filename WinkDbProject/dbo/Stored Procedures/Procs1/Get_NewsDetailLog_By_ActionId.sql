CREATE PROCEDURE [dbo].[Get_NewsDetailLog_By_ActionId]
(
	@action_id int
)
AS
BEGIN
	Declare @action_type varchar(50)
	SET @action_type= (Select action_type from action_log where action_id =@action_id);

	IF(@action_type ='New')
	Begin
		select * from action_log as a,news_olddata_log as o
		where a.action_id = o.action_id 
		and a.action_id = @action_id
	End	
	ELSE IF(@action_type ='Edit')
	BEGIN
		SELECT * 
		from action_log as a, news_olddata_log as o,news_newdata_log as n
		where a.action_id = o.action_id 
		and n.action_id = a.action_id
		and a.action_id = @action_id
	END	
END

