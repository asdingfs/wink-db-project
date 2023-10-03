
CREATE  PROCEDURE [dbo].[GET_Account_Filtering_Status_List_For_Index_V1]

AS
BEGIN


	select distinct filter_procedure_key  ,filter_procedure_name,internal_procedure,procedure_for_index_status from wink_account_filtering_status_new
	where internal_procedure!=5 
	and id != 17 and id != 18
	and filter_procedure_key != 'unlock'
	and filter_procedure_key !='whatsapp_received'
	and filter_procedure_key != 'pending_whatsapp'
	and filter_procedure_key != 'Enquiry_Received'
	and filter_procedure_key != 'pending_clarification'
	and filtering_status =1
	order by procedure_for_index_status



END
