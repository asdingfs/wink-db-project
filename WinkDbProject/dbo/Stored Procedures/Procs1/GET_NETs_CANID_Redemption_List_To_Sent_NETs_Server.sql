CREATE Procedure [dbo].[GET_NETs_CANID_Redemption_List_To_Sent_NETs_Server]
(
 @request_date datetime
 )
AS
Begin
Declare @day int

set @day = 1

if(@request_date is not null and @request_date !='')
BEGIN

SET @request_date = DATEADD(day, -1, @request_date)

END

Declare @current_date datetime

Exec GET_CURRENT_SINGAPORT_DATETIME @current_date output
--- Insert Into Log file before sending
INSERT INTO [dbo].[NETs_CANID_Redemption_Record_SendingLog]
           (
		    [evoucher_amount]
		   ,[redemption_date]
		    ,[can_id]
           ,[customer_id]
           ,[evoucher_id]
           
           ,[created_at]
           ,[updated_at]         
           ,[cronjob_sending_date]
		   ,[cronjob_status]
          )

(select nets.evoucher_amount,nets.redemption_date as created_at,nets.can_id,nets.customer_id
,nets.evoucher_id,@current_date,@current_date,@current_date,'Pending'
 from NETs_CANID_Redemption_Record_Detail as nets ,eVoucher_transaction as e where
nets.evoucher_id = e.eVoucher_id
--and nets.evoucher_amount = e.eVoucher_amount
and (nets.evoucher_amount = 
	CASE 
		WHEN nets.evoucher_amount = 5.00 THEN (e.eVoucher_amount - 1.00)
		ELSE (e.eVoucher_amount - 2.00)
	END
)
and cast (nets.created_at as date) = cast(@request_date as date)
and nets.evoucher_amount>0
and CAST(LEFT(nets.can_id, 4) AS nvarchar) = '1111'
and LEN(nets.can_id)=16
and nets.cronjob_status='pending'
)

union
(select 
 nets.evoucher_amount,nets.redemption_date as created_at,nets.can_id,nets.customer_id
,nets.evoucher_id,@current_date,@current_date,@current_date,'Pending'
 from
 nets_appended_CANID_Redemption_Detail as nets ,eVoucher_transaction as e ,
NETs_CANID_Redemption_Record_Detail as a
where
nets.evoucher_id = e.eVoucher_id
and a.evoucher_id = nets.evoucher_id
and a.cronjob_status ='sent'
--and nets.evoucher_amount = e.eVoucher_amount
and (nets.evoucher_amount = 
	CASE 
		WHEN nets.evoucher_amount = 5.00 THEN (e.eVoucher_amount - 1.00)
		ELSE (e.eVoucher_amount - 2.00)
	END
)
and cast (nets.created_at as date) = cast(@request_date as date)
and nets.evoucher_amount>0
and CAST(LEFT(nets.can_id, 4) AS nvarchar) = '1111'
and LEN(nets.can_id)=16)

-- End Log file 
----- Start to select the data
(select nets.evoucher_amount,nets.redemption_date as created_at,nets.can_id,nets.evoucher_id from NETs_CANID_Redemption_Record_Detail as nets ,eVoucher_transaction as e where
nets.evoucher_id = e.eVoucher_id
--and nets.evoucher_amount = e.eVoucher_amount
and (nets.evoucher_amount = 
	CASE 
		WHEN nets.evoucher_amount = 5.00 THEN (e.eVoucher_amount - 1.00)
		ELSE (e.eVoucher_amount - 2.00)
	END
)
and cast (nets.created_at as date) = cast(@request_date as date)
and nets.evoucher_amount>0
and CAST(LEFT(nets.can_id, 4) AS nvarchar) = '1111'
and LEN(nets.can_id)=16
and nets.cronjob_status='pending'
)

union
(select nets.evoucher_amount,nets.redemption_date as created_at,nets.can_id ,nets.evoucher_id from
 nets_appended_CANID_Redemption_Detail as nets ,eVoucher_transaction as e ,
NETs_CANID_Redemption_Record_Detail as a
where
nets.evoucher_id = e.eVoucher_id
and a.evoucher_id = nets.evoucher_id
and a.cronjob_status ='sent'
--and nets.evoucher_amount = e.eVoucher_amount
and (nets.evoucher_amount = 
	CASE 
		WHEN nets.evoucher_amount = 5.00 THEN (e.eVoucher_amount - 1.00)
		ELSE (e.eVoucher_amount - 2.00)
	END
)
and cast (nets.created_at as date) = cast(@request_date as date)
and nets.evoucher_amount>0
and CAST(LEFT(nets.can_id, 4) AS nvarchar) = '1111'
and LEN(nets.can_id)=16)

END