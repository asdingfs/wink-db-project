
CREATE  PROCEDURE [dbo].[Get_All_WINK_AccountFiltering]
(
 @customer_id varchar (10),
 @request_email varchar(100),
 @request_phone_no varchar(10),
 @registered_phone_no varchar(10),
 @email_request_status varchar(10),
 @whatsapp_request_status varchar(10),
 @filtering_status varchar(50),
 @confiscated_status varchar(10),
 @from_date varchar(30),
 @to_date varchar(30)

)
AS
BEGIN

		IF(@customer_id is null or @customer_id ='')
		set @customer_id = NULL

		IF(@request_email is null or @request_email ='')
		set @request_email = NULL

		IF(@request_phone_no is null or @request_phone_no ='')
		set @request_phone_no = NULL

		IF(@registered_phone_no is null or @registered_phone_no ='')
		set @registered_phone_no = NULL

		IF(@email_request_status is null or @email_request_status ='')
		set @email_request_status = NULL

		IF(@filtering_status is null or @filtering_status ='')
	
		set @filtering_status = NULL
		
		IF(@whatsapp_request_status is null or @whatsapp_request_status ='')
		set @whatsapp_request_status = NULL

		IF(@confiscated_status is null or @confiscated_status ='')
		set @confiscated_status = NULL

	   /* Select * from wink_account_filtering as f,wink_account_filtering_status as s
		where s.filtering_status_key = f.filtering_status
		and (@customer_id is null or f.customer_id =@customer_id)
		and (@request_email is null or f.registered_email like @request_email+'%')
		and (@registered_phone_no is null or f.registered_phone_no =@registered_phone_no)
		and (@request_phone_no is null or f.whatsapp_phone_no =@request_phone_no)
		and (@email_request_status is null or f.email_request_status =@email_request_status)
		and (@whatsapp_request_status is null or f.whatsapp_request_status =@whatsapp_request_status)
		and (@confiscated_status is null or f.confiscated_status =@confiscated_status)
		--and (@filtering_status is null or s.filtering_status_key =@filtering_status)
		and (@filtering_status is null or s.filter_procedure_key =@filtering_status)
		order by f.id desc*/


		Select * from wink_account_filtering as f,wink_account_filtering_status_new as s
				where s.filtering_status_key = f.filtering_status
				and (@customer_id is null or f.customer_id =@customer_id)
				and (@request_email is null or f.registered_email like @request_email+'%')
				and (@registered_phone_no is null or f.registered_phone_no =@registered_phone_no)
				and (@request_phone_no is null or f.whatsapp_phone_no =@request_phone_no)
				and (@email_request_status is null or f.email_request_status =@email_request_status)
				and (@whatsapp_request_status is null or f.whatsapp_request_status =@whatsapp_request_status)
				and (@confiscated_status is null or f.confiscated_status =@confiscated_status)
				--and (@filtering_status is null or s.filtering_status_key =@filtering_status)
				and (@filtering_status is null or s.filter_procedure_key =@filtering_status)

				--and (@reason is null or f.reason like @reason +'%')
				--and (@locked_by is null or f.Locked_by like @locked_by +'%')


END







