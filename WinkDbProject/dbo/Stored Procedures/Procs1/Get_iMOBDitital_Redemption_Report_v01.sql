
CREATE Proc [dbo].[Get_iMOBDitital_Redemption_Report_v01]
( 
  /*@asset_name varchar(50),
  @start_date datetime,
  @end_date datetime,
  @event_name varchar(100),
  @total_scan int,*/
  @email varchar(100),
  @redemption_satus varchar(10),
  @event_name varchar(20)
  )
AS

BEGIN

IF(@redemption_satus='yes')
 BEGIN  
 
  Select c.customer_id,c.first_name +' '+c.last_name as name ,c.email,p.total_scans,r.NRIC,r.dob,r.redemption_status,
   r.created_at as redeemed_at,
   ROW_NUMBER() OVER (Order by r.created_at desc) AS intRow
  from 
 event_winner as valid_customer
 join customer as c
 ON
 valid_customer.customer_id = c.customer_id
 join
 (select COUNT(*) as total_scans , customer_id from 
 customer_earned_points where qr_code like '%Starwars%'
 group by customer_id
 
  ) as p
 on 
 valid_customer.customer_id = p.customer_id
 join wink_digital_redemption as r
 on r.customer_id = valid_customer.customer_id
 where c.email like '%'+@email+'%' 
 and r.redemption_status =1
 
 order by ROW_NUMBER() OVER (Order by r.created_at desc) 
  
 
 END
 ELSE IF (@redemption_satus='no')
 BEGIN
 
   Select c.customer_id,c.first_name +' '+c.last_name as name ,c.email,p.total_scans,r.NRIC,r.dob,r.redemption_status,
   r.created_at as redeemed_at,
   ROW_NUMBER() OVER (Order by r.created_at desc) AS intRow
 
 from 
 event_winner as valid_customer
 join customer as c
 ON
 valid_customer.customer_id = c.customer_id
 join
 (select COUNT(*) as total_scans , customer_id from 
 customer_earned_points where qr_code like '%Starwars%'
 group by customer_id
 
  ) as p
 on 
 valid_customer.customer_id = p.customer_id
 left join wink_digital_redemption as r
 on r.customer_id = valid_customer.customer_id
 where c.email like '%'+@email+'%' 
 and r.redemption_status is null 
 order by ROW_NUMBER() OVER (Order by r.created_at desc) 
 
 END
 Else
 Begin
 
 
  Select c.customer_id,c.first_name +' '+c.last_name as name ,c.email,p.total_scans,r.NRIC,r.dob,r.redemption_status,
   r.created_at as redeemed_at,
   ROW_NUMBER() OVER (Order by r.created_at desc) AS intRow
  --valid_customer.id as intRow
 from 
 event_winner as valid_customer
 join customer as c
 ON
 valid_customer.customer_id = c.customer_id
 join
 (select COUNT(*) as total_scans , customer_id from 
 customer_earned_points where qr_code like '%Starwars%'
 group by customer_id
 
  ) as p
 on 
 valid_customer.customer_id = p.customer_id
 left join wink_digital_redemption as r
 on r.customer_id = valid_customer.customer_id
 where c.email like '%'+@email+'%' 
 order by ROW_NUMBER() OVER (Order by r.created_at desc) 
 
 END



/*
 IF(@redemption_satus='yes')
 BEGIN   
 Select c.customer_id,c.first_name +' '+c.last_name as name ,c.email,p.total_scans,r.NRIC,r.dob,r.redemption_status,
  ROW_NUMBER() OVER(ORDER BY p.total_scans DESC) as intRow  from ( 
 Select customer_id from 
 (select distinct e.customer_id,e.qr_code
from customer_earned_points as e
 where 
 e.qr_code like '%Starwars%'
 and e.customer_id  not in (select distinct customer_id from wink_unentitled_customer_event)
 group by customer_id,qr_code
 
 ) as checking
 group by customer_id 
 having COUNT (*)>=8
 
 ) as valid_customer
 
 join customer as c
 ON
 valid_customer.customer_id = c.customer_id
 join
 (select COUNT(*) as total_scans , customer_id from 
 customer_earned_points where qr_code like '%Starwars%'
 group by customer_id
 
  ) as p
 on 
 valid_customer.customer_id = p.customer_id
 left join wink_digital_redemption as r
 on r.customer_id = valid_customer.customer_id
 where c.email like '%'+@email+'%' 
 and r.redemption_status =1
 
 order by intRow 
 END
 ELSE IF (@redemption_satus='no')
 BEGIN
 Select c.customer_id,c.first_name +' '+c.last_name as name ,c.email,p.total_scans,r.NRIC,r.dob,r.redemption_status,
  ROW_NUMBER() OVER(ORDER BY p.total_scans DESC) as intRow  from ( 
 Select customer_id from 
 (select distinct e.customer_id,e.qr_code
from customer_earned_points as e
 where 
 e.qr_code like '%Starwars%'
 and e.customer_id  not in (select distinct customer_id from wink_unentitled_customer_event)
 group by customer_id,qr_code
 
 ) as checking
 group by customer_id 
 having COUNT (*)>=3
 
 ) as valid_customer
 
 join customer as c
 ON
 valid_customer.customer_id = c.customer_id
 join
 (select COUNT(*) as total_scans , customer_id from 
 customer_earned_points where qr_code like '%Starwars%'
 group by customer_id
 
  ) as p
 on 
 valid_customer.customer_id = p.customer_id
 left join wink_digital_redemption as r
 on r.customer_id = valid_customer.customer_id
 where c.email like '%'+@email+'%' 
 and r.redemption_status is null 
 order by intRow 
 
 END
 Else
 Begin
  Select c.customer_id,c.first_name +' '+c.last_name as name ,c.email,p.total_scans,r.NRIC,r.dob,r.redemption_status,
  ROW_NUMBER() OVER(ORDER BY p.total_scans DESC) as intRow  from ( 
 Select customer_id from 
 (select distinct e.customer_id,e.qr_code
from customer_earned_points as e
 where 
 e.qr_code like '%Starwars%'
 and e.customer_id  not in (select distinct customer_id from wink_unentitled_customer_event)
 group by customer_id,qr_code
 
 ) as checking
 group by customer_id 
 having COUNT (*)>=3
 
 ) as valid_customer
 
 join customer as c
 ON
 valid_customer.customer_id = c.customer_id
 join
 (select COUNT(*) as total_scans , customer_id from 
 customer_earned_points where qr_code like '%Starwars%'
 group by customer_id
 
  ) as p
 on 
 valid_customer.customer_id = p.customer_id
 left join wink_digital_redemption as r
 on r.customer_id = valid_customer.customer_id
 where c.email like '%'+@email+'%' 
 
 order by intRow 
 
 END */
  
 
END

/*insert into event_winner(customer_id,email,event_name,created_at)
Select top 20 c.customer_id,c.email,'starwarspowertube',GETDATE()
 
  from ( 
 Select customer_id from 
 (select distinct e.customer_id,e.qr_code
from customer_earned_points as e
 where 
 e.qr_code like '%Starwars%'
 and cast(created_at as date) between cast('2016-11-27' as date) and cast('2016-11-29' as date)
 and e.customer_id  not in (select distinct customer_id from wink_unentitled_customer_event)
 group by customer_id,qr_code
 
 ) as checking
 group by customer_id 
 having COUNT (*)>=8
 
 ) as valid_customer
 
 join customer as c
 ON
 valid_customer.customer_id = c.customer_id
 and c.status='enable'
 join
 (select COUNT(*) as total_scans , customer_id from 
 customer_earned_points where qr_code like '%Starwars%'
  and cast(created_at as date) between cast('2016-11-27' as date) and cast('2016-11-29' as date)
 group by customer_id
 
  ) as p
 on 
 valid_customer.customer_id = p.customer_id
 left join wink_digital_redemption as r
 on r.customer_id = valid_customer.customer_id
 where c.email like '%'+''+'%' 
 and c.customer_id !=18585
 and c.customer_id !=5050
 and c.customer_id !=24282
  order by p.total_scans desc */
  
