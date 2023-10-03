CREATE PROCEDURE [dbo].[Update_NETs_CreditRebate_Redemption_CronjobStatus]
	(
	 
	 @cronjob_date datetime,
	 @can_id varchar(20),
	 @file_name varchar(20),
	 @transaction_date datetime,
	 @request_date datetime,
	 @txns_error_status varchar(10),
	 @file_success_status varchar(10),
	 @transaction_amount decimal(10,2),
	 @reason varchar(10)
	
	)
AS
BEGIN
Declare @current_date datetime
Declare @cronjob_status varchar(10)
set @cronjob_status ='done'

Declare @day int

set @day = 1

if(@request_date is not null and @request_date !='')
BEGIN

SET @request_date = DATEADD(day, -1, @request_date)

END

Exec GET_CURRENT_SINGAPORT_DATETIME @current_date output  
---- 1. File ED Success
IF (@file_success_status = 'Yes' and @txns_error_status ='No')
BEGIN
	--- Update cronjob status 
		update NETs_CANID_Redemption_Record_Detail set cronjob_success_date = @current_date,
		cronjob_status = @cronjob_status,
		updated_at = @current_date
		where 
		cast (created_at as date) = cast(@request_date as date)
		and cronjob_status ='sent'
		
     --- Update cronjob status from append list due to transaction error 
		update NETs_CANID_Redemption_Record_Detail set cronjob_success_date = @current_date,
		cronjob_status = @cronjob_status, 
		updated_at = @current_date
		where evoucher_id in (select nets.evoucher_id 
		from nets_appended_CANID_Redemption_Detail as nets 
		where cast (nets.created_at as date) = cast(@request_date as date)
		)
		and cronjob_status ='sent'

    ---- Update crojob status from log file 
     update [NETs_CANID_Redemption_Record_SendingLog] set cronjob_success_date = @current_date,
	 cronjob_status = @cronjob_status, 
	 updated_at = @current_date
	 where 
	 cast (created_at as date) = cast(@current_date as date)
      
END
--- 2. File Error 
ELSE IF(@file_success_status = 'No' and @txns_error_status ='No' )
BEGIN

SET @reason = 'FileError'

INSERT INTO [dbo].[NETs_Appended_CANID_Redemption_Detail]
           ([can_id]
           ,[customer_id]
           ,[evoucher_id]
           ,[evoucher_amount]
           ,[created_at]
           ,[updated_at]
           ,[redemption_date]
           ,[error_date]
           ,[file_name]
           ,[reason])
select a.[can_id]
      ,a.[customer_id]
      ,a.[evoucher_id]
      ,a.[evoucher_amount]
      ,@current_date
      ,@current_date
      ,a.[redemption_date],@current_date,@file_name,@reason from NETs_CANID_Redemption_Record_Detail as a ,eVoucher_transaction as e where
a.evoucher_id = e.eVoucher_id
--and a.evoucher_amount = e.eVoucher_amount
and (a.evoucher_amount = 
	CASE 
		WHEN a.evoucher_amount = 5.00 THEN (e.eVoucher_amount - 1.00)
		ELSE (e.eVoucher_amount - 2.00)
	END
)
and a.cronjob_status ='sent'
and a.evoucher_amount>0
and CAST(LEFT(a.can_id, 4) AS nvarchar) = '1111'
and LEN(a.can_id)=16  

--------------------------Log File ------------------------
     update [NETs_CANID_Redemption_Record_SendingLog] set updated_at = @current_date,
	 cronjob_status = 'FileError' where 
	 cast (created_at as date) = cast(@current_date as date) 
 
          

END
--- 3. Txns Error
ELSE IF(@file_success_status = 'No' and @txns_error_status ='Yes' )
BEGIN
print('djfdksjfkd')
Declare @eVoucher_id int

Declare @append_eVoucher_id int

		select top 1 @eVoucher_id = eVoucher_id from NETs_CANID_Redemption_Record_Detail as d where d.can_id =@can_id
		and d.evoucher_amount =@transaction_amount and cast(d.redemption_date as date) = Cast (@transaction_date as date)
		and d.cronjob_status ='sent'
		and d.evoucher_id 
		not in (
				select evoucher_id from NETs_Appended_CANID_Redemption_Detail as e where 
				cast(e.created_at as date) = cast(@current_date as date)
				and e.evoucher_amount =@transaction_amount
				and e.can_id = @can_id
		  )
		  print (@eVoucher_id)
 IF NOT EXISTs (select 1 from NETs_Appended_CANID_Redemption_Detail where evoucher_id =@eVoucher_id
 and cast(created_at as date) =cast(@current_date as date))
	 BEGIN
	 print ('Not Exits')
	 set @reason ='TxnError'
	 INSERT INTO [dbo].[NETs_Appended_CANID_Redemption_Detail]
           ([can_id]
           ,[customer_id]
           ,[evoucher_id]
           ,[evoucher_amount]
           ,[created_at]
           ,[updated_at]
           ,[redemption_date]
           ,[error_date]
           ,[file_name]
           ,[reason])
select a.[can_id]
      ,a.[customer_id]
      ,a.[evoucher_id]
      ,a.[evoucher_amount]
      ,@current_date
      ,@current_date
      ,a.[redemption_date],@current_date,@file_name,@reason from NETs_CANID_Redemption_Record_Detail as a 
	  ,eVoucher_transaction as e where
		a.evoucher_id = e.eVoucher_id
		--and a.evoucher_amount = e.eVoucher_amount
		and (a.evoucher_amount = 
		CASE 
			WHEN a.evoucher_amount = 5.00 THEN (e.eVoucher_amount - 1.00)
			ELSE (e.eVoucher_amount - 2.00)
		END
		)
		and a.evoucher_amount>0
		and CAST(LEFT(a.can_id, 4) AS nvarchar) = '1111'
		and LEN(a.can_id)=16   
		and a.eVoucher_id =@eVoucher_id
     
	 -----------------------------Log File ------------------------
     update [NETs_CANID_Redemption_Record_SendingLog] set updated_at = @current_date,
	 cronjob_status = 'TxnError' where 
	 cast (created_at as date) = cast(@current_date as date)  
	 and evoucher_id = @eVoucher_id   

	 END
END

---- Update the rest of the success records
ELSE IF(@file_success_status = 'No' and @txns_error_status ='Done' )
BEGIN
      set @cronjob_status ='Done'
  --- Update cronjob status 
		update NETs_CANID_Redemption_Record_Detail set cronjob_success_date = @current_date,
		cronjob_status = @cronjob_status,
		updated_at = @current_date
		where 
		cast (created_at as date) = cast(@request_date as date)
		and cronjob_status ='sent'
		and evoucher_id not in 
		(select evoucher_id from NETs_Appended_CANID_Redemption_Detail as e where 
		 cast(e.created_at as date) = cast(@current_date as date)
		  )
		
     --- Update cronjob status from append list due to transaction error 
		update NETs_CANID_Redemption_Record_Detail set cronjob_success_date = @current_date,
		cronjob_status = @cronjob_status, 
		updated_at = @current_date
		where evoucher_id in (select nets.evoucher_id 
		from nets_appended_CANID_Redemption_Detail as nets 
		where cast (nets.created_at as date) = cast(@request_date as date)
		)
		and cronjob_status ='sent'
		and evoucher_id not in (select evoucher_id from NETs_Appended_CANID_Redemption_Detail as e where 
		 cast(e.created_at as date) = cast(@current_date as date)
		  )

    ---- Update crojob status from log file 
     update [NETs_CANID_Redemption_Record_SendingLog] set cronjob_success_date = @current_date,
	 cronjob_status = @cronjob_status, 
	 updated_at = @current_date
	 where 
	 cast (created_at as date) = cast(@current_date as date)
	 and cronjob_status ='sent'
	 /* and evoucher_id not in (select evoucher_id from NETs_Appended_CANID_Redemption_Detail as e where 
		 cast(e.created_at as date) = cast(@current_date as date)
		  )*/

 END


END

