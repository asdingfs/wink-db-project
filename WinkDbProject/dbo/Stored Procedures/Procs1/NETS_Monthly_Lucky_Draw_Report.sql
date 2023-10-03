

CREATE PROCEDURE [dbo].[NETS_Monthly_Lucky_Draw_Report]
(
  
  --@campaign_name varchar(10),
  @customer_id int,
  @email varchar(50),
  @customer_name varchar(100),
  @gender varchar(10),
  @netscanid varchar(50),
  @from_date varchar(20),
  @to_date varchar(20)

  )

AS

BEGIN


Declare @qr_code varchar
set @qr_code ='NETSLuckyDraw_NETSLuckyDraw_NETSLuckyDraw_33944'

--
		IF(@netscanid is null or @netscanid ='')
		set @netscanid = NULL

		IF(@email is null or @email ='')
		set @email = NULL

		IF(@customer_name is null or @customer_name ='')
		set @customer_name = NULL

		IF(@gender is null or @gender ='')
		set @gender = NULL
		
		IF(@customer_id is null or @customer_id ='' or @customer_id =0)
		set @customer_id = NULL

		IF(@from_date is null or @from_date ='' or @to_date is null or @to_date is null)
		BEGIN
		set @from_date = NULL
		set @to_date = NULL

		END

	--	'NETSLuckyDraw_NETSLuckyDraw_NETSLuckyDraw_33944'


	   Select * from (

	  
		SELECT  c.customer_id,
			(c.first_name+' '+ c.last_name ) as customer_name,
			c.gender,
			c.email,
			floor(datediff(day,c.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25) as age,
			customer_earned_points.points as points,
			customer_earned_points.GPS_location as location,
			customer_earned_points.created_at as participated_date,

			(select top 1 can_id.customer_canid from can_id where can_id.customer_id = c.customer_id order by can_id.created_at asc ) as nets_card ,
			(select top 1 can_id.created_at from can_id where can_id.customer_id = c.customer_id order by can_id.created_at asc ) as nets_card_created 
	         from customer as c
			 JOIN customer_earned_points   
			 ON c.customer_id = customer_earned_points.customer_id 
			 WHERE customer_earned_points.qr_code = @qr_code
			     
			 
	
			-------UNION WITH WINK TAG LOG---------------------------





			 ) as TEMP
	   where (@email is null or TEMP.email like '%'+@email+'%')
		and (@customer_name is null or TEMP.customer_name like '%'+@customer_name+'%') 
		and (@customer_id is null or TEMP.customer_id = @customer_id)
		and (@from_date IS NULL OR CAST(TEMP.participated_date as Date) BETWEEN CAST(@from_date as Date) AND CAST(@to_date as Date))
	  order by TEMP.participated_date desc
	
END


