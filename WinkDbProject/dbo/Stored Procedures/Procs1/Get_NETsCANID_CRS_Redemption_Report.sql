CREATE Procedure [dbo].[Get_NETsCANID_CRS_Redemption_Report]
(
  @customer_id int,
  @customer_name varchar(50),
  @customer_email varchar(30),
  @can_id varchar(20),

  @from_date datetime,
  @to_date datetime,
  @cronjob_status varchar(30)
)
As 
Begin

Declare @current_date datetime

EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date OUTPUT   

IF(@customer_id is null or @customer_id ='')
Set @customer_id =NULL

IF(@customer_name is null or @customer_name ='')
Set @customer_name =NULL

IF(@customer_email is null or  @customer_email ='')
Set @customer_email =NULL

IF(@can_id is null or @can_id ='')
Set @can_id =NULL

IF(@cronjob_status is null or @cronjob_status ='')
Set @cronjob_status =NULL

IF (@from_date is null or  @to_date is  null or @from_date='' or @to_date ='')
	BEGIN
	     
			 ---Filter Ready File 
		    IF(@cronjob_status ='ready')
			BEGIN
					Select d.evoucher_id,
					d.customer_id,
					d.can_id,d.cronjob_success_date,
					d.cronjob_status,d.redemption_date,
					e.redeemed_winks as nettopup_winks, 
					d.evoucher_amount,

					c.first_name+' '+ c.last_name as customer_name,
					c.email,d.wink_charges,
					(e.redeemed_winks +d.wink_charges) as total_redeemed_winks
					from NETs_CANID_Redemption_Record_Detail as d
					join customer_earned_evouchers as e
					on d.evoucher_id = e.earned_evoucher_id
					and (CAST ( DATEADD(DAY,3,cronjob_success_date) as date) >= 
					CAST ( @current_date as date)) 
					and (CAST ( DATEADD(DAY,10,cronjob_success_date) as date) >= CAST ( @current_date as date))
					and (@customer_id is null or d.customer_id = @customer_id )
					and (@can_id is null or (d.can_id like +@can_id + '%'))
					and (d.cronjob_status = 'done')
					join
					customer as c
					on
					c.customer_id=d.customer_id  
					and (@customer_name is null or 
					(@customer_name like '%'+first_name + '%' 
					 or 
					 @customer_name like '%'+last_name + '%'))
					and (@customer_email is null or email like @customer_email + '%')
			

					order by d.updated_at desc



			END

			ELSE IF (@cronjob_status ='expired')
			BEGIN
					Select d.evoucher_id,
					d.customer_id,
					d.can_id,d.cronjob_success_date,
					d.cronjob_status,d.redemption_date,
					e.redeemed_winks as nettopup_winks, 
					d.evoucher_amount,

					c.first_name+' '+ c.last_name as customer_name,
					c.email,d.wink_charges,
					(e.redeemed_winks +d.wink_charges) as total_redeemed_winks
					from NETs_CANID_Redemption_Record_Detail as d
					join customer_earned_evouchers as e
					on d.evoucher_id = e.earned_evoucher_id
					/*and (CAST ( DATEADD(DAY,3,cronjob_success_date) as date) >= 
					CAST ( @current_date as date))*/ 
					and (CAST ( DATEADD(DAY,10,cronjob_success_date) as date) <= CAST ( @current_date as date))
					and (@customer_id is null or d.customer_id = @customer_id )
					and (@can_id is null or (d.can_id like +@can_id + '%'))
					and (d.cronjob_status = 'done')
					join
					customer as c
					on
					c.customer_id=d.customer_id  
					and (@customer_name is null or 
					(@customer_name like '%'+first_name + '%' 
					 or 
					 @customer_name like '%'+last_name + '%'))
					and (@customer_email is null or email like @customer_email + '%')
			        

					order by d.updated_at desc

             


			END

			ELSE --IF (@cronjob_status ='pending')
			BEGIN
					Select d.evoucher_id,
					d.customer_id,
					d.can_id,d.cronjob_success_date,
					d.cronjob_status,d.redemption_date,
					e.redeemed_winks as nettopup_winks, 
					d.evoucher_amount,

					c.first_name+' '+ c.last_name as customer_name,
					c.email,d.wink_charges,
					(e.redeemed_winks +d.wink_charges) as total_redeemed_winks
					from NETs_CANID_Redemption_Record_Detail as d
					join customer_earned_evouchers as e
					on d.evoucher_id = e.earned_evoucher_id			    
					and (@customer_id is null or d.customer_id = @customer_id )
					and (@can_id is null or (d.can_id like +@can_id + '%'))
					and (@cronjob_status is null or 
					(d.cronjob_status = @cronjob_status or d.cronjob_status ='sent'	
					or 
					(CAST ( DATEADD(DAY,3,cronjob_success_date) as date) >
					 CAST ( @current_date as date))
					))
					join
					customer as c
					on
					c.customer_id=d.customer_id  
					and (@customer_name is null or 
					(@customer_name like '%'+first_name + '%' 
					 or 
					 @customer_name like '%'+last_name + '%'))
					and (@customer_email is null or email like @customer_email + '%')
			        

					order by d.updated_at desc

             


			END
	

	END
	ELSE
	BEGIN

		 ---Filter Ready File 
		    IF(@cronjob_status ='ready')
			BEGIN
					Select d.evoucher_id,
					d.customer_id,
					d.can_id,d.cronjob_success_date,
					d.cronjob_status,d.redemption_date,
					e.redeemed_winks as nettopup_winks, 
					d.evoucher_amount,

					c.first_name+' '+ c.last_name as customer_name,
					c.email,d.wink_charges,
					(e.redeemed_winks +d.wink_charges) as total_redeemed_winks
					from NETs_CANID_Redemption_Record_Detail as d
					join customer_earned_evouchers as e
					on d.evoucher_id = e.earned_evoucher_id
					and (CAST ( DATEADD(DAY,3,cronjob_success_date) as date) >= 
					cast(@from_date as date)) and 
					(CAST ( DATEADD(DAY,3,cronjob_success_date) as date) <= 
					cast(@to_date as date)
					)
					and (CAST ( DATEADD(DAY,10,cronjob_success_date) as date) >= CAST ( @current_date as date))
					and (@customer_id is null or d.customer_id = @customer_id )
					and (@can_id is null or (d.can_id like +@can_id + '%'))
					and (d.cronjob_status = 'done')
					join
					customer as c
					on
					c.customer_id=d.customer_id  
					and (@customer_name is null or 
					(@customer_name like '%'+first_name + '%' 
					 or 
					 @customer_name like '%'+last_name + '%'))
					and (@customer_email is null or email like @customer_email + '%')
			

					order by d.updated_at desc



			END

			ELSE IF (@cronjob_status ='expired')
			BEGIN
				    Select d.evoucher_id,
					d.customer_id,
					d.can_id,d.cronjob_success_date,
					d.cronjob_status,d.redemption_date,
					e.redeemed_winks as nettopup_winks, 
					d.evoucher_amount,

					c.first_name+' '+ c.last_name as customer_name,
					c.email,d.wink_charges,
					(e.redeemed_winks +d.wink_charges) as total_redeemed_winks
					from NETs_CANID_Redemption_Record_Detail as d
					join customer_earned_evouchers as e
					on d.evoucher_id = e.earned_evoucher_id

					and 
					
					(CAST ( DATEADD(DAY,10,cronjob_success_date) as date) >= 
					cast(@from_date as date) and 
					CAST ( DATEADD(DAY,10,cronjob_success_date) as date) <= 
					cast(@to_date as date)
					)
					
					and (CAST ( DATEADD(DAY,10,cronjob_success_date) as date) <= CAST ( @current_date as date))
					and (@customer_id is null or d.customer_id = @customer_id )
					and (@can_id is null or (d.can_id like +@can_id + '%'))
					and (d.cronjob_status = 'done')
					join
					customer as c
					on
					c.customer_id=d.customer_id  
					and (@customer_name is null or 
					(@customer_name like '%'+first_name + '%' 
					 or 
					 @customer_name like '%'+last_name + '%'))
					and (@customer_email is null or email like @customer_email + '%')
			        

					order by d.updated_at desc

             


			END

			ELSE --IF (@cronjob_status ='pending')
			BEGIN
					Select d.evoucher_id,
					d.customer_id,
					d.can_id,d.cronjob_success_date,
					d.cronjob_status,d.redemption_date,
					e.redeemed_winks as nettopup_winks, 
					d.evoucher_amount,

					c.first_name+' '+ c.last_name as customer_name,
					c.email,d.wink_charges,
					(e.redeemed_winks +d.wink_charges) as total_redeemed_winks
					from NETs_CANID_Redemption_Record_Detail as d
					join customer_earned_evouchers as e
					on d.evoucher_id = e.earned_evoucher_id
					and (cast(d.redemption_date as date) >= 
					cast(@from_date as date) and 
					cast(d.redemption_date as date) <= 
					cast(@to_date as date)
					)
				    
					and (@customer_id is null or d.customer_id = @customer_id )
					and (@can_id is null or (d.can_id like +@can_id + '%'))
					and (@cronjob_status is null or 
					(d.cronjob_status = @cronjob_status or d.cronjob_status ='sent'	
					or 
					(CAST ( DATEADD(DAY,3,cronjob_success_date) as date) >
					 CAST ( @current_date as date))
					))
					join
					customer as c
					on
					c.customer_id=d.customer_id  
					and (@customer_name is null or 
					(@customer_name like '%'+first_name + '%' 
					 or 
					 @customer_name like '%'+last_name + '%'))
					and (@customer_email is null or email like @customer_email + '%')
			        

					order by d.updated_at desc

             


			END
		
	END

	--select * from customer_earned_evouchers where earned_evoucher_id =4351

	
  
 
End


/*Select * from NETs_CANID_Redemption_Record_Detail

update NETs_CANID_Redemption_Record_Detail set updated_at = created_at where updated_at is null

alter table NETs_CANID_Redemption_Record_Detail add wink_charges int default 0 not null
--select *  from NETs_CANID_Redemption_Record_Detail 

select * from wink_confiscated_detail 

alter table wink_confiscated_detail add evoucher_id int 

update NETs_CANID_Redemption_Record_Detail set evoucher_amount =1 where evoucher_id=4352
*/

/*Select * from NETs_CANID_Redemption_Record_Detail order by created_at desc

select * from customer where customer.customer_id =2837*/