
CREATE Proc [dbo].[Get_iMOBSpecial_Ditital_Redemption_Report]
( 
  /*@asset_name varchar(50),
  @start_date datetime,
  @end_date datetime,
  @event_name varchar(100),
  @total_scan int,*/
  @email varchar(100),
  @redemption_satus varchar(10),
  @event_name varchar(100)
  )
AS

BEGIN

IF(@redemption_satus='yes')
 BEGIN  
 
  Select c.customer_id,c.first_name +' '+c.last_name as name ,c.email,r.NRIC,r.dob,r.redemption_status,
   r.created_at as redeemed_at,
   ROW_NUMBER() OVER (Order by r.created_at desc) AS intRow
  from iMOBSpecial
  as valid_customer
 join customer as c
 ON
 valid_customer.customer_id = c.customer_id
 join customer_earned_evouchers as p
 on p.earned_evoucher_id = valid_customer.eVoucher_id
 join wink_digital_redemption as r
 on r.customer_id = valid_customer.customer_id
 where c.email like '%'+@email+'%' 
 and valid_customer.event_name =@event_name
 and r.redemption_status = 1
 and r.event_name =@event_name
 
 order by ROW_NUMBER() OVER (Order by r.created_at desc) 
  
 
 END
 ELSE IF (@redemption_satus='no')
 BEGIN  
 
  Select c.customer_id,c.first_name +' '+c.last_name as name ,c.email,r.NRIC,r.dob,r.redemption_status,
   r.created_at as redeemed_at,
   ROW_NUMBER() OVER (Order by r.created_at desc) AS intRow
  from iMOBSpecial
  as valid_customer
 join customer as c
 ON
 valid_customer.customer_id = c.customer_id
 join customer_earned_evouchers as p
 on p.earned_evoucher_id = valid_customer.eVoucher_id
 left join wink_digital_redemption as r
 on r.customer_id = valid_customer.customer_id
 and r.event_name = @event_name
 where c.email like '%'+@email+'%' 
 and valid_customer.event_name =@event_name
 and r.redemption_status is null
 
 order by ROW_NUMBER() OVER (Order by r.created_at desc) 
  
 
 END
 Else
 BEGIN  
 
  Select c.customer_id,c.first_name +' '+c.last_name as name ,c.email,r.NRIC,r.dob,r.redemption_status,
   r.created_at as redeemed_at,
   ROW_NUMBER() OVER (Order by r.created_at desc) AS intRow
  from iMOBSpecial
  as valid_customer
 join customer as c
 ON
 valid_customer.customer_id = c.customer_id
 join customer_earned_evouchers as p
 on p.earned_evoucher_id = valid_customer.eVoucher_id
 left join wink_digital_redemption as r
 on r.customer_id = valid_customer.customer_id
  and r.event_name =@event_name
 where c.email like '%'+@email+'%' 
 and valid_customer.event_name =@event_name
  
 order by ROW_NUMBER() OVER (Order by r.created_at desc) 
  
 
 END
 
END


--select * from iMOBSpecial where event_name ='Starwars20161202'