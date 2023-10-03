

CREATE PROCEDURE [dbo].[Get_NETs_Report_By_EventName_v1]
(
	@wid varchar(50),
	@start_date varchar(50),    
	@end_date varchar(50),
	@event_name varchar(100),
	@email varchar(50),
	@customer_name varchar(50),
	@can_id varchar(20),
	@customer_id varchar(10)  
)
	
AS
BEGIN

	IF (@wid is null or @wid = '')
	BEGIN
		SET @wid = NULL;
	END
	IF(@email is null or @email ='')
	BEGIN
		set @email = NULL;
	END

	IF(@can_id is null or @can_id ='')
	BEGIN
		set @can_id = NULL;
	END
	IF(@customer_id is null or @customer_id ='')
	BEGIN
		set @customer_id = NULL;
	END
	IF(@customer_name is null or @customer_name ='')
	BEGIN
		set @customer_name = NULL;
	END
	IF (@start_date IS NOT NULL AND @end_date IS NOT NULL AND @start_date!='' AND @end_date !='')
	BEGIN

		SELECT P.customer_id,P.can_id,([customer].first_name + ' ' + [customer].last_name) as customer_name, 
		[customer].email,[customer].WID as wid, p.business_date
		, p.total_points, p.total_tabs				
				
		FROM wink_net_canid_earned_points As P, customer

		where customer.customer_id = P.customer_id
		and CAST(p.business_date as DATE)>= CAST(@start_date as DATE)    
		AND CAST(p.business_date as DATE)<= CAST(@end_date as DATE)
		and p.promotion_name =@event_name
		and (@customer_id is null or (p.customer_id like '%'+@customer_id))
		 and (@customer_name is null  or (customer.first_name like '%'+@customer_name+'%' or customer.last_name like '%'+@customer_name+'%'))
		 and (@email is null or (email like '%'+ @email+'%'))
		 and (@can_id is null or (p.can_id like '%'+ @can_id+'%'))
		 AND (@wid is null or customer.wid like '%'+@wid+'%')
		order by P.business_date desc




END

ELSE

BEGIN

		SELECT P.customer_id,P.can_id,([customer].first_name + ' ' + [customer].last_name) as customer_name, 
		[customer].email,[customer].WID as wid, customer.created_at as customer_since,p.business_date
		, p.total_points, p.total_tabs				
				
		FROM wink_net_canid_earned_points As P, customer

		where customer.customer_id = P.customer_id
		and p.promotion_name =@event_name
		 and (@customer_id is null or (p.customer_id like '%'+@customer_id))
		 and (@customer_name is null  or (customer.first_name like '%'+@customer_name+'%' or customer.last_name like '%'+@customer_name+'%'))
		 and (@email is null or (email like '%'+ @email+'%'))
		 and (@can_id is null or (p.can_id like '%'+ @can_id+'%'))
		 AND (@wid is null or customer.wid like '%'+@wid+'%')
		order by P.business_date desc


END

END


