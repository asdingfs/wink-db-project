
CREATE PROCEDURE [dbo].[WINKTAG_GET_SIMPLIFIED_REPORT_VALIDITY_WINKHUNT_testing_14092023]
      @customer_name varchar(200),
    @email varchar(200),
	@gender varchar(200),
	@customer_id int,
	@start_date varchar(50),
	@end_date varchar(50),
	@winktag_report varchar(50),
    @promo_code varchar(16),
	@wid varchar(50),
	@status varchar(50),
	@validity varchar(10)
AS
BEGIN
    DECLARE @CAMPAIGN_ID int;
	
	IF (@start_date is null or @start_date = '')
		SET @start_date = NULL;

	IF (@end_date is null or @end_date = '')
		SET @end_date = NULL;

	IF(@customer_name is null or @customer_name ='')
		SET @customer_name = NULL

	IF(@email is null or @email ='')
		SET @email = NULL

	IF(@gender is null or @gender ='')
	SET @gender = NULL

	IF(@customer_id = 0)
		SET @customer_id = NULL

	IF(@wid is null or @wid ='')
		SET @wid = NULL

	IF(@status is null or @status='')
		SET @status = NULL

	IF(@validity is null or @validity='')
		SET @validity = NULL
        
    IF(@promo_code is null or @promo_code = '')
        SET @promo_code = NULL
	
	IF NOT EXISTS(SELECT * FROM winktag_campaign WHERE winktag_report = @winktag_report)
        --WINKHUNT CHANGES--
        IF (@winktag_report = 'WinkHuntUserEngagementReport')
        BEGIN
            SET @CAMPAIGN_ID = (SELECT campaign_id FROM winktag_campaign WHERE winktag_report = 'WinkHuntNewUserReport')
            DECLARE @SECOND_CAMPAIGN_ID INT = (SELECT campaign_id FROM winktag_campaign WHERE winktag_report = 'WinkHuntExistingUserReport')
          -- GOTO Winkhunt
			print('r1')
        END
        ELSE IF (@winktag_report = 'WinkHuntSurveyPhase1Report')
        BEGIN
            SET @CAMPAIGN_ID = (SELECT campaign_id FROM winktag_campaign WHERE winktag_report = 'WinkHuntSurveyPhase1Report')       
			print('r2')
		END
        ELSE
        BEGIN
            RETURN;
        END
	ELSE
	BEGIN
		SET @CAMPAIGN_ID = (SELECT CAMPAIGN_ID FROM winktag_campaign WHERE winktag_report = @winktag_report)
		print('exists')
    END
          DECLARE @user_type VARCHAR(20) = '';

    IF(@CAMPAIGN_ID = 211 or @CAMPAIGN_ID = 212 or @CAMPAIGN_ID = 215)
        BEGIN
  

            IF(@CAMPAIGN_ID = 211)
            BEGIN
                SET @user_type = 'New'
				
            END
            ELSE IF(@CAMPAIGN_ID = 212)
            BEGIN
                SET @user_type = 'Existing'
				
            END
			print('215')
            SELECT * FROM 
				(--1 START
					SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS no,CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.status as status,
					T.customer_id,T.points,T.user_type,T.promo_code,T.GPS_location,T.ip_address,T.created_at,
					T.Q1
					
					FROM

					(
						-----table1
						SELECT * from
						(SELECT customer_id,0 as points, @user_type as user_type,''as promo_code,location as GPS_location,ip_address,created_at, '' as Q1
						from winktag_customer_action_log 
							WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0
							AND (@customer_id is null or customer_id = @customer_id)
							AND (@start_date IS NULL OR CAST(created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
						) as T1
						-----table1

						UNION
	
						-----table2
						SELECT LOG.customer_id, CODE.wink_point_value AS points, @user_type as user_type, CODE.promo_code as promo_code, LOG.location AS GPS_location, LOG.ip_address, LOG.created_on AS created_at,
                        (
                            CASE
                                WHEN EXISTS (
                                    SELECT 1 FROM TBL_WINKPLAY_WINKHUNT_CUSTOMER_CODES_LOG AS L
                                    JOIN TBL_WINKPLAY_WINKHUNT_CODES AS C
                                    ON L.WP_WH_CODES_ID = C.WP_WH_CODES_ID
                                    WHERE C.campaign_id = @CAMPAIGN_ID 
                                    AND (@customer_id is null or L.customer_id = @customer_id)
                                ) THEN '1'
                                ELSE ''
                            END
                        ) AS Q1
                        FROM TBL_WINKPLAY_WINKHUNT_CUSTOMER_CODES_LOG AS LOG
                        JOIN TBL_WINKPLAY_WINKHUNT_CODES AS CODE
                        ON LOG.WP_WH_CODES_ID = CODE.WP_WH_CODES_ID
                        WHERE CODE.campaign_id = @CAMPAIGN_ID 
                        AND (@customer_id is null or LOG.customer_id = @customer_id)
						AND (@start_date IS NULL OR CAST(LOG.created_on as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))

					) AS T 
					INNER JOIN CUSTOMER ON T.customer_id = CUSTOMER.customer_id 
					WHERE ( @validity is null 
							or (@validity = 'Yes' AND T.Q1 != '')  
							or (@validity = '0' AND T.Q1 = ''))
						
				) AS TEMP----1 END
				WHERE (@email is null or TEMP.email like '%'+@email+'%')
				and (@gender is null or TEMP.gender = @gender)
				AND (@wid is null or TEMP.wid like '%'+@wid+'%')
				AND (@customer_name is null or TEMP.customer_name like '%'+@customer_name+'%') 
				AND (@status is null or TEMP.status = @status)
                AND (@promo_code is null or TEMP.promo_code like '%'+@promo_code+'%')
			 
				order by temp.no desc
        END
	ELSE IF(@CAMPAIGN_ID=217)
	    BEGIN
		print('217')
				SELECT * FROM 
				(--1 START
					SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS [no],CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.[status] as [status],
					T.points,T.created_at,
					T.Q1
					
					FROM

					(
						-----table1
						SELECT * from
						(SELECT campaign_id,customer_id,0 as points,created_at, 
						'' as Q1

						from winktag_customer_action_log 
							WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0
							AND (@customer_id is null or customer_id = @customer_id)
							AND (@start_date IS NULL OR CAST(created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
						) as T1
						-----table1

						UNION
	
						-----table2
						SELECT C.campaign_id,C.customer_id,C.points,C.created_at,
						(
							SELECT answer FROM winktag_customer_survey_answer_detail AS T1 
							WHERE T1.customer_id = C.customer_id and T1.campaign_id = @CAMPAIGN_ID and T1.question_no = 'Q1' AND T1.row_count = C.row_count
						) as Q1
						
						FROM winktag_customer_earned_points AS C WHERE C.campaign_id = @CAMPAIGN_ID  
						AND (@customer_id is null or C.customer_id = @customer_id)
						AND (@start_date IS NULL OR CAST(C.created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
						-----table2

					) AS T 
					INNER JOIN CUSTOMER ON T.customer_id = CUSTOMER.customer_id 
					WHERE @validity is null 
							or (@validity = 'Yes' AND T.Q1 != '')  
							or (@validity = '0' AND T.Q1 = '')
				) AS TEMP----1 END
				WHERE (@email is null or TEMP.email like '%'+@email+'%')
				and (@gender is null or TEMP.gender = @gender)
				AND (@wid is null or TEMP.wid like '%'+@wid+'%')
				AND (@customer_name is null or TEMP.customer_name like '%'+@customer_name+'%') 
				AND (@status is null or TEMP.status = @status)
			 
				order by temp.no desc
	END
  
	

   -- Winkhunt:
   -- BEGIN
   --      print('winkhunt')
		 --SELECT * FROM 
			--	(--1 START
			--		SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS no,CUSTOMER.first_name +' '+CUSTOMER.last_name as customer_name,CUSTOMER.email,CUSTOMER.gender,(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,Customer.WID as wid, Customer.status as status,
			--		T.customer_id,T.points,T.user_type,T.promo_code,T.GPS_location,T.ip_address,T.created_at,
			--		T.Q1
					
			--		FROM

			--		(
			--			-----table1
			--			SELECT * from
			--			(SELECT customer_id,0 as points,'New' as user_type, '' as promo_code, location as GPS_location,ip_address,created_at, '' as Q1
			--			from winktag_customer_action_log 
			--				WHERE campaign_id = @CAMPAIGN_ID and survey_complete_status = 0
			--				AND (@customer_id is null or customer_id = @customer_id)
			--				AND (@start_date IS NULL OR CAST(created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
			--			) as T1

			--			UNION
	
			--			-----table2
   --                     SELECT * FROM (SELECT LOG.customer_id, CODE.wink_point_value AS points, 'New' as user_type, CODE.promo_code as promo_code, LOG.location AS GPS_location, LOG.ip_address, LOG.created_on AS created_at,
   --                     (
   --                         CASE
   --                             WHEN EXISTS (
   --                                 SELECT 1 FROM TBL_WINKPLAY_WINKHUNT_CUSTOMER_CODES_LOG AS L
   --                                 JOIN TBL_WINKPLAY_WINKHUNT_CODES AS C
   --                                 ON L.WP_WH_CODES_ID = C.WP_WH_CODES_ID
   --                                 WHERE C.campaign_id = @CAMPAIGN_ID 
   --                                 AND (@customer_id is null or L.customer_id = @customer_id)
   --                             ) THEN '1'
   --                             ELSE ''
   --                         END
   --                     ) AS Q1
   --                     FROM TBL_WINKPLAY_WINKHUNT_CUSTOMER_CODES_LOG AS LOG
   --                     JOIN TBL_WINKPLAY_WINKHUNT_CODES AS CODE
   --                     ON LOG.WP_WH_CODES_ID = CODE.WP_WH_CODES_ID
   --                     WHERE CODE.campaign_id = @CAMPAIGN_ID 
   --                     AND (@customer_id is null or LOG.customer_id = @customer_id)
			--			AND (@start_date IS NULL OR CAST(LOG.created_on as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
   --                     ) AS T2
						
   --                     UNION
   --                     -----table3
			--			SELECT * from
			--			(SELECT customer_id,0 as points,'Existing' as user_type, '' as promo_code, location as GPS_location,ip_address,created_at, '' as Q1
			--			from winktag_customer_action_log 
			--				WHERE campaign_id = @SECOND_CAMPAIGN_ID and survey_complete_status = 0
			--				AND (@customer_id is null or customer_id = @customer_id)
			--				AND (@start_date IS NULL OR CAST(created_at as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
			--			) as T3

   --                     UNION
   --                     -----table4
   --                     SELECT * FROM (SELECT LOG.customer_id, CODE.wink_point_value AS points, 'Existing' as user_type, CODE.promo_code as promo_code, LOG.location AS GPS_location, LOG.ip_address, LOG.created_on AS created_at,
   --                     (
   --                         CASE
   --                             WHEN EXISTS (
   --                                 SELECT 1 FROM TBL_WINKPLAY_WINKHUNT_CUSTOMER_CODES_LOG AS L
   --                                 JOIN TBL_WINKPLAY_WINKHUNT_CODES AS C
   --                                 ON L.WP_WH_CODES_ID = C.WP_WH_CODES_ID
   --                                 WHERE C.campaign_id = @SECOND_CAMPAIGN_ID 
   --                                 AND (@customer_id is null or L.customer_id = @customer_id)
   --                             ) THEN '1'
   --                             ELSE ''
   --                         END
   --                     ) AS Q1
   --                     FROM TBL_WINKPLAY_WINKHUNT_CUSTOMER_CODES_LOG AS LOG
   --                     JOIN TBL_WINKPLAY_WINKHUNT_CODES AS CODE
   --                     ON LOG.WP_WH_CODES_ID = CODE.WP_WH_CODES_ID
   --                     WHERE CODE.campaign_id = @SECOND_CAMPAIGN_ID 
   --                     AND (@customer_id is null or LOG.customer_id = @customer_id)
			--			AND (@start_date IS NULL OR CAST(LOG.created_on as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
   --                     ) AS T4
                    
			--		) AS T 
			--		INNER JOIN CUSTOMER ON T.customer_id = CUSTOMER.customer_id 
			--		WHERE ( @validity is null 
			--				or (@validity = 'Yes' AND T.Q1 != '')  
			--				or (@validity = '0' AND T.Q1 = ''))
						
			--	) AS TEMP----1 END
			--	WHERE (@email is null or TEMP.email like '%'+@email+'%')
			--	and (@gender is null or TEMP.gender = @gender)
			--	AND (@wid is null or TEMP.wid like '%'+@wid+'%')
			--	AND (@customer_name is null or TEMP.customer_name like '%'+@customer_name+'%') 
			--	AND (@status is null or TEMP.status = @status)
   --             AND (@promo_code is null or TEMP.promo_code like '%'+@promo_code+'%')
			 
			--	order by temp.no desc

   -- END
	
END
