CREATE PROC [dbo].[WINKTAG_GET_CUSTOMER_ACTION_LOG_BY_CAMPAIGN]
(
	@customer_name varchar(200),
	@email varchar(200),
	@gender varchar(200),
	@customer_id int,
	@start_date varchar(50),
	@end_date varchar(50),
	@winktag_report varchar(50),
	@survey_complete_status varchar(50),
	@CAMPAIGN_ID int
)

AS

BEGIN

		SELECT * FROM 
		(--1 START
			SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC) AS no, T.*,T.first_name +' '+T.last_name as customer_name,(select floor(datediff(day,T.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,
			'' as Q1, '' as Q2,'' as Q3 ,'' as Q4 , '' as Q5,'No' as survey_complete_status,'' AS points
			FROM

			(
				SELECT A.campaign_id,A.customer_id,location as GPS_location,A.ip_address,A.created_at,c.first_name,c.last_name,c.email,c.gender,c.date_of_birth
				FROM winktag_customer_action_log AS A
				INNER JOIN CUSTOMER AS C
				ON A.CUSTOMER_ID = C.CUSTOMER_ID
				WHERE A.CAMPAIGN_ID = @CAMPAIGN_ID

			) AS T 
			

		) AS TEMP----1 END
		WHERE (@email is null or Temp.email like '%'+@email+'%')
		and (@gender is null or TEMP.gender = @gender)
		and (@customer_name is null or TEMP.customer_name like '%'+@customer_name+'%') 
		and (@customer_id is null or TEMP.customer_id = @customer_id)
		and (@start_date IS NULL OR CAST(TEMP.created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
		order by temp.no desc

END