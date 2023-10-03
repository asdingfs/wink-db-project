CREATE procedure [dbo].[Create_NETs_NonStop_EarnedPoints]
(
 @can_id varchar(20),
 @tran_type varchar (10),
 @tran_date varchar (50),
 @tran_amount decimal(10,2)
)
As 
BEGIN
Declare @Customer_id int 
Declare @created_date datetime
Declare @total_points int



Exec GET_CURRENT_SINGAPORT_DATETIME @created_date output



set @total_points = 1;
--- For Top UP Points 
if(@tran_type ='02' OR @tran_type ='03' OR @tran_type ='03' OR @tran_type='79' OR @tran_type='82')
BEGIN
--- 1$ = 1 point
set @total_points = CAST(@tran_amount AS int)

END

set @Customer_id = (select c.customer_id from customer as c ,can_id as can 
where c.customer_id = can.customer_id
and can.customer_canid = @can_id
and c.status ='enable')

print (@Customer_id)



	IF (@Customer_id is not null and @Customer_id !=0 and @Customer_id!='')
	BEGIN
	--- For ERP and CP reject invalid amount

		IF(@tran_type = '07' or @tran_type ='01')
			BEGIN
			--print ('07 or 01')
				IF (@tran_amount>0)
				BEGIN
				IF NOT Exists (select 1 from nonstop_net_canid_earned_points where cast(business_date as datetime) = cast(@tran_date as datetime) and card_type = @tran_type and can_id = @can_id)
				BEGIN
				--print ('aaa')
				insert into nonstop_net_canid_earned_points 
				(customer_id ,created_at,business_date,can_id,card_type,total_points,trans_amount,updated_at)
				values (@Customer_id,@created_date,@tran_date,@can_id,@tran_type,@total_points,@tran_amount,@created_date)
				END
						ELSE 
						BEGIN
						print ('bbb')
							insert into nonstop_net_canid_earned_points_errorlog (customer_id ,created_at,business_date,can_id,card_type,total_points,trans_amount)
				             values (@Customer_id,@created_date,@tran_date,@can_id,@tran_type,@total_points,@tran_amount)
						END
				END
						/*ELse
						BEGIN
						print ('ccc')
						END*/
			END

		ELSE --- For Top UP allow negative value
			BEGIN
				IF NOT Exists (select 1 from nonstop_net_canid_earned_points where cast(business_date as datetime) = cast(@tran_date as datetime) and card_type = @tran_type and can_id = @can_id)
				BEGIN
				print ('ddd')
				insert into nonstop_net_canid_earned_points (customer_id ,created_at,business_date,can_id,card_type,total_points,trans_amount,updated_at)
				values (@Customer_id,@created_date,@tran_date,@can_id,@tran_type,@total_points,@tran_amount,@created_date)
				END
				ELse 
					BEGIN
					print ('eee')
					insert into nonstop_net_canid_earned_points_errorlog (customer_id ,created_at,business_date,can_id,card_type,total_points,trans_amount)
				    values (@Customer_id,@created_date,@tran_date,@can_id,@tran_type,@total_points,@tran_amount)
					END
			END


	END


END

--select * from nonstop_net_canid_earned_points order by created_at desc

--select * from can_id

--select updated_at from  nonstop_net_canid_earned_points



