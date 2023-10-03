CREATE PROCEDURE [dbo].[Get_Current_Available_WINKs_Internal_backup] 
	
AS
BEGIN

Declare @current_date datetime
Declare @year varchar(10)

Set @year ='2017'
EXEC GET_CURRENT_SINGAPORT_DATETIME  @current_date OUTPUT

/*
		EXEC GET_CURRENT_SINGAPORT_DATETIME  @current_date OUTPUT
		SET @year =Year (DATEADD(year,-1,@current_date))

		print (@year)

		IF(@year = Year(@current_date))
		set @year=''*/

	select 
	
	total_winks_For_customer_to_redeem - total_winks_From_customer_balance as current_avaiable_winks,
	yearly_end_confiscated_winks_From_customer_balance,year_end_total_winks_From_wink_confiscated_detail,
	(total_winks_For_customer_to_redeem - total_winks_From_customer_balance) + yearly_end_confiscated_winks_From_customer_balance as final_winks_after_winks_expired,
	campaign_total_winks,
	
	campaign_total_winks_confiscated,total_winks_For_customer_to_redeem,total_winks_From_customer_balance,total_winks_From_customer_earned_winks, used_winks_From_customer_balance,confiscated_winks_From_customer_balance
	

			 from (

			(select sum(total_winks) as campaign_total_winks,sum(total_wink_confiscated) as campaign_total_winks_confiscated,
			sum(total_winks) + sum(total_wink_confiscated) as total_winks_For_customer_to_redeem, 1 as id
			from campaign 
			where campaign_status='enable' and 
			cast(campaign_start_date as date) <= cast(@current_date as date)
			
			) 
			as c
			join
			(
			select sum(used_winks) as used_winks_From_customer_balance, 
			sum(total_winks) as total_winks_From_customer_balance,  1 as id ,
			sum(confiscated_winks) as confiscated_winks_From_customer_balance,
			
			sum(total_winks- used_winks - confiscated_winks) as yearly_end_confiscated_winks_From_customer_balance
			
			from customer_balance as b


			where customer_id != 15
			) as b
			on b.id = c.id

			join
			(
			select sum(total_winks) as total_winks_From_customer_earned_winks,  1 as id from customer_earned_winks 
			where customer_id != 15
			) as d
			on d.id = c.id


			join
			(
			select sum(total_winks) as year_end_total_winks_From_wink_confiscated_detail,  1 as id from wink_confiscated_detail  as d
			where customer_id != 15 and d.year_end =@year
			) as e
			on e.id = c.id
			)
		



END


