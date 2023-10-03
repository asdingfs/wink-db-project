

CREATE PROCEDURE [dbo].[WinTag_Lucky_Draw_Report]
(
  
  --@campaign_name varchar(10),
  @incampaign_id int,
  @customer_id int,
  @email varchar(50),
  @customer_name varchar(100),
  @gender varchar(10),
  @netscanid varchar(50), 
    @from_date varchar(20),
  @to_date varchar(20),
   @inQR_code varchar(250)
    
  )

AS

BEGIN

DECLARE @CURRENT_DATE DATETIME
EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATE OUTPUT

--Declare @qr_code varchar
--set @qr_code =@inQR_code   --'NETSLuckyDraw_NETSLuckyDraw_NETSLuckyDraw_33944'


	IF(@netscanid is null or @netscanid ='')
		set @netscanid = NULL

		IF(@email is null or @email ='')
		set @email = NULL

		IF(@customer_name is null or @customer_name ='')
		set @customer_name = NULL

		IF(@gender is null or @gender ='')
		set @gender = NULL
		
		IF(@customer_id is null or @customer_id =0 or @customer_id='' )
		set @customer_id = NULL

		IF(@inQR_code is null or @inQR_code ='')
		set @inQR_code = NULL
		
		IF(@incampaign_id is null or @incampaign_id =0 )
		set @incampaign_id = 1

		IF(@from_date is null or @from_date ='' or @to_date is null or @to_date ='')
		BEGIN
		set @from_date = NULL
		set @to_date = NULL

		END


	  
	  IF @from_date is null
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
			 WHERE customer_earned_points.qr_code = @inQR_code
			and @inQR_code is not null
			     
			 union
			SELECT  c.customer_id,
			(c.first_name+' '+ c.last_name ) as customer_name,
			c.gender,
			c.email,
			floor(datediff(day,c.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25) as age,
			w.points as points,
			w.location as location,
			w.created_at as participated_date,
			'' as nets_card,
			null as nets_card_created 
	         from customer as c
			 JOIN winners_points  as w
			 ON c.customer_id = w.customer_id 
			 WHERE w.entry_id = @incampaign_id
			     and @inQR_code is null

			 ) as TEMP
	   where (@email is null or TEMP.email like '%'+@email+'%')
			and (@customer_name is null or TEMP.customer_name like '%'+@customer_name+'%') 
			and (@gender is null or TEMP.gender = @gender)
		and (@customer_id is null or TEMP.customer_id = @customer_id)
		and ( (CAST(TEMP.participated_date as Date) BETWEEN CAST(@CURRENT_DATE as Date) AND CAST(@CURRENT_DATE as Date)))

	  order by TEMP.participated_date desc
	  ELSE
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
			 WHERE customer_earned_points.qr_code = @inQR_code
			and @inQR_code is not null
			     
			 union
			SELECT  c.customer_id,
			(c.first_name+' '+ c.last_name ) as customer_name,
			c.gender,
			c.email,
			floor(datediff(day,c.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25) as age,
			w.points as points,
			w.location as location,
			w.created_at as participated_date,
			'' as nets_card,
			null as nets_card_created 
	         from customer as c
			 JOIN winners_points  as w
			 ON c.customer_id = w.customer_id 
			 WHERE w.entry_id = @incampaign_id
			     and @inQR_code is null

			 ) as TEMP
	   where (@email is null or TEMP.email like '%'+@email+'%')
			and (@customer_name is null or TEMP.customer_name like '%'+@customer_name+'%') 
			and (@gender is null or TEMP.gender = @gender)
		and (@customer_id is null or TEMP.customer_id = @customer_id)
		and (/*@from_date is null OR*/ (CAST(TEMP.participated_date as Date) BETWEEN CAST(@from_date as Date) AND CAST(@to_date as Date)))
	  order by TEMP.participated_date desc
	
END