CREATE PROCEDURE [dbo].[Check_Customer_Balance_For_internal_backup] 
	
AS
BEGIN
Declare @current_date datetime
exec GET_CURRENT_SINGAPORT_DATETIME @current_date output
	---- 1. CHECKING ONE (FOR CHECKING CUSTOMER POINTS ONLY)
	
	-----START 
	
		/*select customer_id, total_points, total_scan_points,trip_points,net_trip_points,wink_play_points ,cic_points,

		(summary.total_points - summary.total_scan_points -summary.net_trip_points - summary.trip_points -summary.wink_play_points-cic_points) 
		 from (
		select b.customer_id ,Sum(b.total_points) as total_points,Sum(ISNULL(points.total_scan_points,0)) as total_scan_points, Sum(ISNULL(trip_points,0)) as trip_points ,Sum(ISNULL(net_trip_points,0)) as net_trip_points ,Sum(ISNULL(wink_play_points,0)) as wink_play_points, sum(isnull(cic_points,0))as cic_points from customer_balance as b 
		left join
		(
		select sum(p.points) as total_scan_points , p.customer_id from customer_earned_points as p 
		group by customer_id ) as points
		on b.customer_id = points.customer_id

		left join
		(
		select sum(p.total_points) as trip_points , p.customer_id from wink_canid_earned_points as p 
		group by customer_id ) as trip
		on b.customer_id = trip.customer_id

		left join
		(
		select sum(p.total_points) as net_trip_points , p.customer_id from wink_net_canid_earned_points as p 
		group by customer_id ) as net_trip
		on b.customer_id = net_trip.customer_id

		left join
		(
		select sum(p.points) as wink_play_points , p.customer_id from winktag_customer_earned_points as p 
		group by customer_id ) as wink_play
		on b.customer_id = wink_play.customer_id 

		left join
		(
		select sum(p.total_points) as cic_points , p.customer_id from cic_table as p 
		group by customer_id ) as cic
		on b.customer_id = cic.customer_id 
		group by b.customer_id
		) as summary


		where (summary.total_points - summary.total_scan_points -summary.net_trip_points - summary.trip_points -summary.wink_play_points-summary.cic_points)< 0
		*/
		-----END

		
		---- 2. CHECKING TWO (FOR CHECKING POINTS , WINKS , EVOUCHER)

			--- START
			/*IF EXISTS (SELECT 1 FROM (
			select redeemed_points_From_customer_earned_winks,used_points_FROM_customer_balance,total_winks_from_customer_earned_winks, total_winks_FROM_customer_balance_ ,
			customer_earned_evoucher_redeemed_winks,used_winks_FROM_customer_balance_,customer_earned_evoucher_eVoucher_amount 
			from 
			(
			(Select sum(total_winks) as total_winks_From_customer_earned_winks, 
			sum(redeemed_points) as redeemed_points_From_customer_earned_winks, 
			sum(redeemed_points)/50 as redeemed_points_divide_by_50 ,1 as id from customer_earned_winks as w) as a
			join 

			(Select sum(total_winks) as total_winks_FROM_customer_balance_, sum(used_winks) as used_winks_FROM_customer_balance_,
			sum(used_points) as used_points_FROM_customer_balance ,1 as id from customer_balance as w
			where customer_id !=15
			) as b

			on a.id = b.id
			JOIN
			(Select sum(redeemed_winks) as customer_earned_evoucher_redeemed_winks,
			 sum(eVoucher_amount) as customer_earned_evoucher_eVoucher_amount,
			 1 as id from customer_earned_evouchers as w
			where customer_id !=15
			) as c
			on c.id = b.id
			 )
			 ) AS CHECK_POINTS WHERE CHECK_POINTS.used_points_FROM_customer_balance <> CHECK_POINTS.redeemed_points_From_customer_earned_winks)
			 BEGIN

			 SELECT 0 AS RESPONSE_CODE , 'Redeem points do not mathch' as response_message
			 END 
			 ---CHECK REDEEM WINKS AND USED WINKS
			 ELSE IF EXISTS (SELECT 1 FROM (
			select redeemed_points_From_customer_earned_winks,used_points_FROM_customer_balance,total_winks_from_customer_earned_winks, total_winks_FROM_customer_balance_ ,
			customer_earned_evoucher_redeemed_winks,used_winks_FROM_customer_balance_,customer_earned_evoucher_eVoucher_amount 
			from 
			(
			(Select sum(total_winks) as total_winks_From_customer_earned_winks, 
			sum(redeemed_points) as redeemed_points_From_customer_earned_winks, 
			sum(redeemed_points)/50 as redeemed_points_divide_by_50 ,1 as id from customer_earned_winks as w) as a
			join 

			(Select sum(total_winks) as total_winks_FROM_customer_balance_, sum(used_winks) as used_winks_FROM_customer_balance_,
			sum(used_points) as used_points_FROM_customer_balance ,1 as id from customer_balance as w
			where customer_id !=15
			) as b

			on a.id = b.id
			JOIN
			(Select sum(redeemed_winks) as customer_earned_evoucher_redeemed_winks,
			 sum(eVoucher_amount) as customer_earned_evoucher_eVoucher_amount,
			 1 as id from customer_earned_evouchers as w
			where customer_id !=15
			) as c
			on c.id = b.id
			 )
			 ) AS CHECK_WINKS WHERE CHECK_WINKS.customer_earned_evoucher_redeemed_winks <> CHECK_WINKS.used_winks_FROM_customer_balance_)
			 BEGIN

			 SELECT 0 AS RESPONSE_CODE , 'Redeem WINKS do not mathch' as response_message
			 END 

			 ---CHECK REDEEM POINTS MUST MATCH WITH AND TOTAL WINKS
			 ELSE IF EXISTS (SELECT 1 FROM (
			select redeemed_points_From_customer_earned_winks,used_points_FROM_customer_balance,total_winks_from_customer_earned_winks, total_winks_FROM_customer_balance_ ,
			customer_earned_evoucher_redeemed_winks,used_winks_FROM_customer_balance_,customer_earned_evoucher_eVoucher_amount 
			from 
			(
			(Select sum(total_winks) as total_winks_From_customer_earned_winks, 
			sum(redeemed_points) as redeemed_points_From_customer_earned_winks, 
			sum(redeemed_points)/50 as redeemed_points_divide_by_50 ,1 as id from customer_earned_winks as w) as a
			join 

			(Select sum(total_winks) as total_winks_FROM_customer_balance_, sum(used_winks) as used_winks_FROM_customer_balance_,
			sum(used_points) as used_points_FROM_customer_balance ,1 as id from customer_balance as w
			where customer_id !=15
			) as b

			on a.id = b.id
			JOIN
			(Select sum(redeemed_winks) as customer_earned_evoucher_redeemed_winks,
			 sum(eVoucher_amount) as customer_earned_evoucher_eVoucher_amount,
			 1 as id from customer_earned_evouchers as w
			where customer_id !=15
			) as c
			on c.id = b.id
			 )
			 ) AS CHECK_WINKS WHERE CHECK_WINKS.total_winks_From_customer_earned_winks <> CHECK_WINKS.used_points_FROM_customer_balance/50)
			 BEGIN

			 SELECT 0 AS RESPONSE_CODE , 'TOTAL WINKS do not mathch  with redeemed points' as response_message
			 END 
			 ELSE 
			 BEGIN

			 SELECT 1 AS RESPONSE_CODE , 'NO ERROR' as response_message
			 END

			 --- END -------------------------------------------------------

			 */


--------- 3. CHECKING THREE (FOR CHECKING  WINKS FROM CAMPAIGN , CONFISCATED WINKS, CUSTOMER EARNED WINKS)

			---START-------------------------------
			IF EXISTS (select 1 from (
			select campaign_total_winks,campaign_total_winks_confiscated,total_winks_For_customer_to_redeem,total_winks_From_customer_balance,total_winks_From_customer_earned_winks, used_winks_From_customer_balance,

			total_winks_For_customer_to_redeem - total_winks_From_customer_balance as current_avaiable_winks

			 from (

			(select sum(total_winks) as campaign_total_winks,sum(total_wink_confiscated) as campaign_total_winks_confiscated,
			sum(total_winks) + sum(total_wink_confiscated) as total_winks_For_customer_to_redeem, 1 as id
			from campaign
			where campaign_status='enable' and 
			cast(campaign_start_date as date) <= cast(@current_date as date)
			 ) as c
			join
			(
			select sum(used_winks) as used_winks_From_customer_balance, sum(total_winks) as total_winks_From_customer_balance,  1 as id from customer_balance as b
			where customer_id != 15
			) as b
			on b.id = c.id

			join
			(
			select sum(total_winks) as total_winks_From_customer_earned_winks,  1 as id from customer_earned_winks 
			where customer_id != 15
			) as d
			on d.id = c.id
			)
			) as winks
			where (winks.total_winks_For_customer_to_redeem <winks.total_winks_From_customer_earned_winks )
			or  (winks.total_winks_For_customer_to_redeem <winks.total_winks_From_customer_balance )

			)
			BEGIN

			SELECT 0 AS RESPONSE_CODE , 'Total winks for customer to redeem do not match with the actual customer earned winks' as response_message

			END

			ELSE IF EXISTS (select 1 from (
			select campaign_total_winks,campaign_total_winks_confiscated,total_winks_For_customer_to_redeem,total_winks_From_customer_balance,total_winks_From_customer_earned_winks, used_winks_From_customer_balance,

			total_winks_For_customer_to_redeem - total_winks_From_customer_balance as current_avaiable_winks

			 from (

			(select sum(total_winks) as campaign_total_winks,sum(total_wink_confiscated) as campaign_total_winks_confiscated,
			sum(total_winks) + sum(total_wink_confiscated) as total_winks_For_customer_to_redeem, 1 as id
			from campaign 
			where campaign_status='enable' and 
			cast(campaign_start_date as date) <= cast(@current_date as date)
			) as c
			join
			(
			select sum(used_winks) as used_winks_From_customer_balance, sum(total_winks) as total_winks_From_customer_balance,  1 as id from customer_balance as b
			where customer_id != 15
			) as b
			on b.id = c.id

			join
			(
			select sum(total_winks) as total_winks_From_customer_earned_winks,  1 as id from customer_earned_winks 
			where customer_id != 15
			) as d
			on d.id = c.id
			)
			) as winks
			where (winks.used_winks_From_customer_balance > winks.total_winks_From_customer_earned_winks )
			or  (winks.used_winks_From_customer_balance > winks.total_winks_From_customer_balance )

			)
			BEGIN

			SELECT 0 AS RESPONSE_CODE , 'Total winks for customer to redeem do not match with the actual customer earned winks' as response_message

			END
			ELSE IF EXISTS (select 1 from (
			select campaign_total_winks,campaign_total_winks_confiscated,total_winks_For_customer_to_redeem,total_winks_From_customer_balance,total_winks_From_customer_earned_winks, used_winks_From_customer_balance,

			total_winks_For_customer_to_redeem - total_winks_From_customer_balance as current_avaiable_winks,
			redeemed_winks_From_customer_earned_evouchers

			 from (

			(select sum(total_winks) as campaign_total_winks,sum(total_wink_confiscated) as campaign_total_winks_confiscated,
			sum(total_winks) + sum(total_wink_confiscated) as total_winks_For_customer_to_redeem, 1 as id
			from campaign 
			where campaign_status='enable' and 
			cast(campaign_start_date as date) <= cast(@current_date as date)
			) as c
			join
			(
			select sum(used_winks) as used_winks_From_customer_balance, sum(total_winks) as total_winks_From_customer_balance,  1 as id from customer_balance as b
			where customer_id != 15
			) as b
			on b.id = c.id

			join
			(
			select sum(total_winks) as total_winks_From_customer_earned_winks,  1 as id from customer_earned_winks 
			where customer_id != 15
			) as d
			on d.id = c.id
			)

			join
			(
			select sum(k.redeemed_winks) as redeemed_winks_From_customer_earned_evouchers,  1 as id from customer_earned_evouchers as k
			where customer_id != 15
			) as e
			on e.id = c.id

			) as winks
			where (winks.used_winks_From_customer_balance <> winks.redeemed_winks_From_customer_earned_evouchers )
			or  (winks.redeemed_winks_From_customer_earned_evouchers > winks.total_winks_For_customer_to_redeem )

			)
			BEGIN

			SELECT 0 AS RESPONSE_CODE , '2.Total winks for customer to redeem do not match with the actual customer earned winks' as response_message

			END
			ELSE 
			BEGIN
			SELECT 1 AS RESPONSE_CODE , 'No Error' as response_message
			END

			---END-------------------------------------




END


