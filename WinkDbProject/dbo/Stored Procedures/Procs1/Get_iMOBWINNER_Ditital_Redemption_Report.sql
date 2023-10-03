
CREATE Proc [dbo].[Get_iMOBWINNER_Ditital_Redemption_Report]
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
 
   Select valid_customer.customer_id, valid_customer.imob_customer_id, valid_customer.name ,valid_customer.email,r.NRIC,r.dob,r.redemption_status,
   r.created_at as redeemed_at,
   ROW_NUMBER() OVER (Order by r.created_at desc) AS intRow
  from imobpurchase_event_winner as valid_customer
  join iMOBWINNER_digital_redemption as r
  on r.imob_customer_id= valid_customer.imob_customer_id
  and r.event_name =@event_name
  and valid_customer.event_name =@event_name
  where valid_customer.email like '%'+@email+'%' 
  and r.redemption_status = 1
 
 order by ROW_NUMBER() OVER (Order by r.created_at desc) 
  
 
 END
 ELSE IF (@redemption_satus='no')
 BEGIN  
 
    Select valid_customer.customer_id, valid_customer.imob_customer_id, valid_customer.name ,valid_customer.email,r.NRIC,r.dob,r.redemption_status,
   r.created_at as redeemed_at,
   ROW_NUMBER() OVER (Order by r.created_at desc) AS intRow
  from imobpurchase_event_winner as valid_customer
  left join iMOBWINNER_digital_redemption as r
  on r.imob_customer_id= valid_customer.imob_customer_id
  and r.event_name =@event_name
  and valid_customer.event_name =@event_name
  where valid_customer.email like '%'+@email+'%' 
  and r.redemption_status is null
 
 order by ROW_NUMBER() OVER (Order by r.created_at desc) 
 
 END
 Else
 BEGIN  
 
  Select valid_customer.customer_id, valid_customer.imob_customer_id, valid_customer.name ,valid_customer.email,r.NRIC,r.dob,r.redemption_status,
   r.created_at as redeemed_at,
   ROW_NUMBER() OVER (Order by r.created_at desc) AS intRow
  from imobpurchase_event_winner as valid_customer
  left join iMOBWINNER_digital_redemption as r
  on r.imob_customer_id= valid_customer.imob_customer_id
  and r.event_name =@event_name
  and valid_customer.event_name =@event_name
  where valid_customer.email like '%'+@email+'%' 
  
 
 END
 
END


--select * from iMOBSpecial where event_name ='Starwars20161202'

--select * from imobpurchase_event_winner