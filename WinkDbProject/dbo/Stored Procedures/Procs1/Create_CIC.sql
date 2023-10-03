CREATE PROCEDURE [dbo].[Create_CIC]
	(@can_id varchar(50),
	-- @dob varchar(150),
	 @nric varchar(50),
	 @amount decimal (10,2),
	 @action_email varchar(200),
	 @file_name varchar(150),
	 @action_type varchar(50)
	
	)
AS
BEGIN
Declare @current_date datetime
Declare @error int
Declare @transaction_fee decimal(10,2)
Declare @total_points decimal (10,2)

/*Declare @points_per_winks decimal (10,2)
Declare @cents_per_winks decimal(10,2)*/
Declare @point_per_cents decimal (10,2)
Declare @customer_id int 
Declare @cent_amount decimal(10,2)

Declare @total_amount decimal (10,2)

Declare @total_transaction_fee decimal (10,2)

Declare @used_amount decimal (10,2)

Declare @used_transaction_fee decimal (10,2)

Declare @balanced_amount decimal (10,2)

Declare @balanced_transaction decimal (10,2)

set @total_amount = 3000
set @total_transaction_fee = 1200
Exec GET_CURRENT_SINGAPORT_DATETIME @current_date output  


select @used_amount = sum(c.amount),@used_transaction_fee = SUM(c.transaction_fees) from cic_table as c
where Month(created_at)= MONTH(@current_date)
and YEAR(created_at) = YEAR(@current_date)

Set @balanced_amount = @total_amount - @used_amount

set @balanced_transaction = @total_transaction_fee - @used_transaction_fee


if(@balanced_transaction<0.20)
BEGIN
insert into cic_table_log(customer_id , can_id , nric,amount,total_points,transaction_fees,created_at,reason,action_type,action_email,cic_file_name)
     values (@customer_id,@can_id,@nric,@amount,@total_points,0,@current_date,'Transaction fees limit reach',@action_type,@action_email,@file_name)
	 select 0 as success , 'Transaction fees limit reach' as response_message ,MAX(a.id) as id from cic_table_log as a
     Return
END


if(@balanced_amount<@amount)
BEGIN
insert into cic_table_log(customer_id , can_id , nric,amount,total_points,transaction_fees,created_at,reason,action_type,action_email,cic_file_name)
     values (@customer_id,@can_id,@nric,@amount,@total_points,0,@current_date,'Amount limit reach',@action_type,@action_email,@file_name)
	 select 0 as success , 'Amount limit reach' as response_message ,MAX(a.id) as id from cic_table_log as a
     Return
END



--set @cents_per_winks = (select rate_conversion.rate_value from rate_conversion where rate_code='cents_per_wink')
--set @points_per_winks = (select rate_conversion.rate_value from rate_conversion where rate_code='points_per_wink')
set @transaction_fee = 0.20
-- covert to cents
set @cent_amount = @amount*100
set @point_per_cents = 1
set @total_points = @point_per_cents * @cent_amount

Set @customer_id =0

    IF(@can_id is null or @can_id ='' )
    BEGIN
     insert into cic_table_log(customer_id , can_id , nric,amount,total_points,transaction_fees,created_at,reason,action_type,action_email,cic_file_name)
     values (@customer_id,@can_id,@nric,@amount,@total_points,0,@current_date,'Invalid CAN ID',@action_type,@action_email,@file_name)
	 select 0 as success , 'CAN ID can not be empty' as response_message ,MAX(a.id) as id from cic_table_log as a
	 
	 RETURN
    END
    
    ELSE IF(@nric is null or @nric ='' )
    BEGIN
     insert into cic_table_log(customer_id , can_id , nric,amount,total_points,transaction_fees,created_at,reason,action_type,action_email,cic_file_name)
     values (@customer_id,@can_id,@nric,@amount,@total_points,0,@current_date,'Invalid NRIC',@action_type,@action_email,@file_name)
	 select 0 as success , 'Email can not be empty' as response_message,MAX(a.id) as id from cic_table_log as a
	 
	 RETURN
    END 
        
    IF EXISTS (select 1 from can_id where can_id.customer_canid= @can_id )
    BEGIN
   
    Select @customer_id = can_id.customer_id from can_id where customer_canid = @can_id    
    /*
    
    Set @customer_id =(select can_id.customer_id from can_id,customer where 
    can_id.customer_id = customer.customer_id
    and can_id.customer_canid =@can_id
    and customer.status ='enable')*/
           
    IF(@customer_id is not null or @customer_id !='')
		BEGIN
		
		
		IF NOT EXISTS ( select 1 from customer where customer.customer_id = @customer_id
		 and email = @nric)
			BEGIN
		 insert into cic_table_log(customer_id , can_id , nric,amount,total_points,transaction_fees,created_at,reason,action_type,action_email,cic_file_name)
			 values (@customer_id,@can_id,@nric,@amount,@total_points,0,@current_date,'Mismatch between CAN ID and email',@action_type,@action_email,@file_name)
			 select 0 as success , 'Mismatch between CAN ID and email' as response_message ,MAX(a.id) as id from cic_table_log as a
			Return
    
    
		 END
		 
		-- Check Account is Locked	
		IF EXISTS (select 1 from customer where customer_id = @customer_id and status = 'disable')
		BEGIN
	     insert into cic_table_log(customer_id , can_id , nric,amount,total_points,transaction_fees,created_at,reason,action_type,action_email,cic_file_name)
	    values (@customer_id,@can_id,@nric,@amount,@total_points,0,@current_date,'Customer account is locked',@action_type,@action_email,@file_name)
	    select 0 as success , 'Customer account is locked' as response_message ,MAX(a.id) as id from cic_table_log as a
	     Return
	    END
		
		
		
		
		IF(@amount>0)
		BEGIN
		insert into cic_table(customer_id , can_id , nric,amount,total_points,transaction_fees,created_at,action_type,action_email,cic_file_name)
		values (@customer_id,@can_id,@nric,@amount,@total_points,@transaction_fee,@current_date,@action_type,@action_email,@file_name)
        IF(@@ERROR=0 and @@ROWCOUNT >0)
        BEGIN
         update customer_balance set total_points = total_points + CAST(@total_points as int)
         where customer_id = @customer_id
         IF(@@ERROR=0)
         BEGIN
          select 1 as success , 'successfully added' as response_message
          return
         END
         
        END
        
        END
        ELSE
        BEGIN
        insert into cic_table_log(customer_id , can_id , nric,amount,total_points,transaction_fees,created_at,reason,action_type,action_email,cic_file_name)
		 values (@customer_id,@can_id,@nric,@amount,@total_points,0,@current_date,'Invalid Amount',@action_type,@action_email,@file_name)
		 select 0 as success , 'Invalid Amount' as response_message ,MAX(a.id) as id from cic_table_log as a
        Return
        END
        
    
    
		END
	ELSE
	BEGIN
	 insert into cic_table_log(customer_id , can_id , nric,amount,total_points,transaction_fees,created_at,reason,action_type,action_email,cic_file_name)
	 values (@customer_id,@can_id,@nric,@amount,@total_points,0,@current_date,'Customer account is locked',@action_type,@action_email,@file_name)
	 select 0 as success , 'Customer account is locked' as response_message ,MAX(a.id) as id from cic_table_log as a
	 Return
	END
    
    END
    Else
    BEGIN
    
    insert into cic_table_log(customer_id , can_id , nric,amount,total_points,transaction_fees,created_at,reason,action_type,action_email,cic_file_name)
	 values (@customer_id,@can_id,@nric,@amount,@total_points,0,@current_date,'CAN ID does not exist',@action_type,@action_email,@file_name)
    select 0 as success , 'CAN ID does not exist' as response_message,MAX(a.id) as id from cic_table_log as a
    Return
    
    END
    
	
END
