
CREATE PROCEDURE [dbo].[Get_All_WINK_AccountFiltering_V1]
(
@customer_name varchar(200),
 @wid varchar (10),
 @customer_id varchar (10),
 @request_email varchar(100),
 @request_phone_no varchar(10),
 @registered_phone_no varchar(10),
 @email_request_status varchar(10),
 @whatsapp_request_status varchar(10),
 @filtering_status varchar(50),
 @confiscated_status varchar(10),
 @from_date varchar(30),
 @to_date varchar(30),
 @reason varchar(255),
 @locked_by varchar(150),
 @end_suspension varchar(10)
)
AS
BEGIN
		DECLARE @CURRENT_DATE Date;     
		EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATE OUTPUT 

		IF(@customer_name is null or @customer_name ='')
			SET @customer_name = NULL;

		IF(@wid is null or @wid ='')
			set @wid = NULL
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

	    IF(@reason is null or @reason ='')
		set @reason = NULL
				
	    IF(@locked_by is null or @locked_by ='')
		set @locked_by = NULL

		
		IF(@end_suspension is null or @end_suspension ='')
		BEGIN
			set @end_suspension = NULL;
		END
		

		 IF(@from_date is null or @from_date ='')
		set @from_date = NULL


		 IF(@to_date is null or @to_date ='')
		set @to_date = NULL
		IF (@to_date IS NULL)
		BEGIN
				Select f.*, s.*, c.WID, (c.first_name+' '+c.last_name) as customer_name
				from wink_account_filtering as f,wink_account_filtering_status_new as s, customer as c
				where s.filtering_status_key = f.filtering_status
				and f.customer_id = c.customer_id
				AND (@customer_name is null or (c.first_name+' '+c.last_name) like '%'+@customer_name+'%')
				and (@wid is null or c.WID like '%'+ @wid +'%')
				and (@customer_id is null or f.customer_id =@customer_id)
				and (@request_email is null or f.registered_email like  '%'+ @request_email+'%')
				and (@registered_phone_no is null or f.registered_phone_no like  '%'+ @registered_phone_no+'%')
				and (@request_phone_no is null or f.whatsapp_phone_no like  '%'+ @request_phone_no+'%')
				and (@email_request_status is null or f.email_request_status =@email_request_status)
				and (@whatsapp_request_status is null or f.whatsapp_request_status =@whatsapp_request_status)
				and (@confiscated_status is null or f.confiscated_status =@confiscated_status)
				--and (@filtering_status is null or s.filtering_status_key =@filtering_status)
				and (@filtering_status is null or s.filter_procedure_key =@filtering_status)
				AND (
						(@end_suspension = 'Yes' AND (f.End_suspension_date is not null and f.End_suspension_date !=''))
						OR
						(@end_suspension = 'No' AND (f.End_suspension_date is null or f.End_suspension_date = ''))
						OR
						(@end_suspension is NULL)
					)
				and (@reason is null or f.reason like '%'+ @reason +'%')
				and (@locked_by is null or f.Locked_by like  '%'+ @locked_by +'%')
		


				order by f.updated_at desc
		END
		ELSE 
		BEGIN
			Select f.*, s.*, c.WID, (c.first_name+' '+c.last_name) as customer_name 
			from wink_account_filtering as f,wink_account_filtering_status_new as s, customer as c
				where s.filtering_status_key = f.filtering_status
				and f.customer_id = c.customer_id
				AND (@customer_name is null or (c.first_name+' '+c.last_name) like '%'+@customer_name+'%')
				and (@wid is null or c.WID like '%'+ @wid +'%')
				and (@customer_id is null or f.customer_id =@customer_id)
				and (@request_email is null or f.registered_email like  '%'+ @request_email+'%')
				and (@registered_phone_no is null or f.registered_phone_no like  '%'+ @registered_phone_no+'%')
				and (@request_phone_no is null or f.whatsapp_phone_no like  '%'+ @request_phone_no+'%')
				and (@email_request_status is null or f.email_request_status =@email_request_status)
				and (@whatsapp_request_status is null or f.whatsapp_request_status =@whatsapp_request_status)
				and (@confiscated_status is null or f.confiscated_status =@confiscated_status)
				and (@filtering_status is null or s.filter_procedure_key =@filtering_status)
				AND (
						(@end_suspension = 'Yes' AND (f.End_suspension_date is not null and f.End_suspension_date !=''))
						OR
						(@end_suspension = 'No' AND (f.End_suspension_date is null or f.End_suspension_date = ''))
						OR
						(@end_suspension is NULL)
					)
				and (@reason is null or f.reason like '%'+ @reason +'%')
				and (@locked_by is null or f.Locked_by like '%'+ @locked_by +'%')
				and cast(f.diasbled_date as date ) >= cast(@from_date as date )
				and cast(f.diasbled_date as date ) <= cast(@to_date as date )


				order by f.updated_at desc

		END

END


--select * from wink_account_filtering




