
CREATE  PROCEDURE [dbo].[GET_Account_Filtering_Status_List_For_Index]

AS
BEGIN

	/*select * from wink_account_filtering_status  as data
	where data.filtering_status_key != 'Confiscation_Suspension_Recommend' and data.Filtering_status_key != 'confiscation_recommend'

    and data.Filtering_status_key != 'Confiscation_and_Suspension_30_days' and data.Filtering_status_key != 'Confiscation_and_Suspension_7_days' and
    data.Filtering_status_key != 'further_investigation' and data.Filtering_status_key != 'remark_update' and
    data.Filtering_status_key != 'no_panelty_unlocking_approved' and data.Filtering_status_key != 'confiscation_and_suspension' 
	and data.Filtering_status_key != 'confiscation_only'
	and data.filtering_status_key !='unlocked'
	and data.filtering_status_key != 'approved'
	and data.filtering_status_key != 'onhold'
	and data.filtering_status_key != 'other'
	order by data.filtering_status_name */
 select * from (
	select distinct a.filter_procedure_key as filtering_status_key, 
	filter_procedure_name as filtering_status_name 
	from wink_account_filtering_status as a
	where a.filter_procedure_key = 'done' or 
	a.filter_procedure_key = 'pending_remark'
	or a.filter_procedure_key = 'dev_updated'
	or a.filter_procedure_key = 'final_approval'
	or a.filter_procedure_key ='Enquiry_Received'
	or a.filter_procedure_key ='new'
	or a.filter_procedure_key ='pending_whatsapp'
	or a.filter_procedure_key ='pending_clarification'
	or a.filter_procedure_key ='') as a
	order by a.filtering_status_name
    

END



