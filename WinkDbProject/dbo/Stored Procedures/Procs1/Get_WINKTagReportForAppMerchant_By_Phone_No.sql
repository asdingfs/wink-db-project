
CREATE PROC [dbo].[Get_WINKTagReportForAppMerchant_By_Phone_No]
(
 @campaign_id int ,
 @phone_no varchar(20)
)
AS
BEGIN

DECLARE @CURRENT_DATETIME Datetime ;     
EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUTPUT 
if (@campaign_id =0)
BEGIN
set @campaign_id =4
END
--- Production winktag status must be 0
/*If Exists (select 1 from winktag_campaign WHERE WINKTAG_STATUS = 0 and survey_type ='merchant'
AND CONVERT(DATE,@CURRENT_DATETIME) >= CONVERT(DATE,from_date)
AND CONVERT(DATE,@CURRENT_DATETIME) <= CONVERT(DATE,to_date) and campaign_id =@campaign_id )*/

--- testing
If Exists (select 1 from winktag_campaign WHERE WINKTAG_STATUS = 1 and survey_type ='merchant'
AND CONVERT(DATE,@CURRENT_DATETIME) >= CONVERT(DATE,from_date)
AND CONVERT(DATE,@CURRENT_DATETIME) <= CONVERT(DATE,to_date) and campaign_id =@campaign_id )
BEGIN
-- Check valid phone no.
    IF EXISTS (select 1 from winktag_approved_phone_list where campaign_id =@campaign_id and phone_no=@phone_no)
	BEGIN

	set @campaign_id = @campaign_id -1
	

	select *
				from
				(
				  select count(*) as total,1 as response_code,c.gender,cam.size,cam.size as total_size,
				cast(ans.created_at as date) as created_at 
				from winktag_customer_earned_points as ans  
				
				join customer as c
				on c.customer_id = ans.customer_id
				and ans.campaign_id = @campaign_id
				and ans.points =20
				 

				join winktag_campaign as cam
				on cam.campaign_id = ans.campaign_id
				

				group by c.gender,cast(ans.created_at as date),c.gender,cam.size
				--order by cast(ans.created_at as date)
				) d
				pivot
				(
				  max(total)
				 for gender in (Female, Male)

				) piv
				order by piv.created_at desc

	END
	ELSE
	BEGIN
	select 0 as response_code , 'Opps! You are not in the invite list.' as response_message
	Return
	END

END
ELse
BEGIN

select 0 as response_code , 'No campaign' as response_message
Return
END


	 
END

--select * from winktag_approved_phone_list