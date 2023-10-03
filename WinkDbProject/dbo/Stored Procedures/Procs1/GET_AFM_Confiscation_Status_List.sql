
CREATE  PROCEDURE [dbo].[GET_AFM_Confiscation_Status_List]

AS
BEGIN


	select * from wink_account_filtering_status_new
	where (internal_procedure =4
	or id =26)
	and id !=23
	order by filtering_status_name



END
