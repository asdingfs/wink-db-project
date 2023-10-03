-- =============================================
CREATE PROCEDURE [dbo].[Get_AccountFilteringLogDetail_By_ActionId]
	(@action_id int)
AS
BEGIN
Declare @action_type varchar(50)

SET @action_type= (Select action_type from action_log where action_id =@action_id)
print (@action_type)
IF(@action_type ='Edit')
   Begin
	select * from action_log as a

	join 

	( SELECT  
       action_id as old_action_id,
       [customer_id] as old_customer_id
      ,[old_registered_email]
      ,[old_WINKs_in_eWallet]
      ,[old_points_in_eWallet]
      ,[old_last_expired_evoucher]
      ,[old_registered_phone_no]
      ,[old_whatsapp_phone_no]
      ,[old_diasbled_date]
      ,[old_whatsapp_received_date]
      ,[old_email_request_status]
      ,[old_whatsapp_request_status]
      ,[old_offender_status]
      ,[old_reason]
      ,[old_confiscated_status]
      ,[old_confiscation_batch]
      ,[old_filtering_status]
      ,[old_unlocked_date]
      ,[old_remark]
     
      ,[old_enquiry_received_date]
      ,[old_confiscated_date]
      ,[enquiry_received_date]
	  ,s.filtering_status_name as old_filtering_status_name
  FROM [dbo].[wink_account_filtering_olddata_log] as old , wink_account_filtering_status as s
  where old.old_filtering_status = s.filtering_status_key
  and old.action_id = @action_id ) as old

  on a.action_id = old.old_action_id
  and a.action_id = @action_id 

  JOIN 
  (

  SELECT 
       [action_id] as new_action_id
      ,[action_email]
      ,[customer_id]
      ,[registered_email]
      ,[WINKs_in_eWallet]
      ,[points_in_eWallet]
      ,[last_expired_evoucher]
      ,[registered_phone_no]
      ,[whatsapp_phone_no]
      ,[diasbled_date]
      ,[whatsapp_received_date]
      ,[email_request_status]
      ,[whatsapp_request_status]
      ,[offender_status]
      ,[reason]
      ,[confiscated_status]
      ,[confiscation_batch]
      ,s.filtering_status
      ,[unlocked_date]
      ,[remark]
     
      ,[enquiry_received_date]
      ,[confiscated_date]
	  ,s.filtering_status_name as new_filtering_status_name
  FROM [dbo].[wink_account_filtering_newdata_log] as new,wink_account_filtering_status as s
  where new.filtering_status = s.filtering_status_key
  and new.action_id = @action_id ) as new

  on a.action_id = new.new_action_id
  and a.action_id = @action_id 

	
	
	End
	
ElSE
	Begin
	
	select * from action_log as a

	join 

	( SELECT  
       action_id as old_action_id,
       [customer_id] as old_customer_id
      ,[old_registered_email]
      ,[old_WINKs_in_eWallet]
      ,[old_points_in_eWallet]
      ,[old_last_expired_evoucher]
      ,[old_registered_phone_no]
      ,[old_whatsapp_phone_no]
      ,[old_diasbled_date]
      ,[old_whatsapp_received_date]
      ,[old_email_request_status]
      ,[old_whatsapp_request_status]
      ,[old_offender_status]
      ,[old_reason]
      ,[old_confiscated_status]
      ,[old_confiscation_batch]
      ,[old_filtering_status]
      ,[old_unlocked_date]
      ,[old_remark]
     
      ,[old_enquiry_received_date]
      ,[old_confiscated_date]
      ,[enquiry_received_date]
	  ,s.filtering_status_name as old_filtering_status_name
  FROM [dbo].[wink_account_filtering_olddata_log] as old , wink_account_filtering_status as s
  where old.old_filtering_status = s.filtering_status_key
  and old.action_id = @action_id ) as old

  on a.action_id = old.old_action_id
  and a.action_id = @action_id 
	
	End
	
END

/*select * from action_log where action_id =211

select * from campaign_olddata_log

Select action_type from action_log where action_id =211*/
