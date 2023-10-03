CREATE PROCEDURE [dbo].[Get_Ads_Trackers_Simplified]
(
	@report varchar(250),
	@campaignName varchar(250),
	@url varchar(250),
	@wid varchar(50),
	@customer_id int,
	@customer_name varchar(200),
	@email varchar(200),
	@gender varchar(200),
	@from_date varchar(50),
	@to_date varchar(50),
	@ip_address varchar(20)
 )
As
BEGIN
Declare @current_datetime datetime

Exec GET_CURRENT_SINGAPORT_DATETIME @current_datetime output

	IF (@report is null or @report='')
	BEGIN
		set @report= NULL;
	END

	IF (@campaignName is null or @campaignName='')
	BEGIN
		set @campaignName= NULL;
	END
	ELSE
	BEGIN
		IF(@campaignName = 'iOS')
		BEGIN
			SET @campaignName = 'iphone'
		END
		ELSE IF(@campaignName = 'Android')
		BEGIN
			SET @campaignName = 'android'
		END
	END

	IF (@url is null or @url='')
	BEGIN
		set @url= NULL;
	END

	IF(@customer_name is null or @customer_name ='')
	BEGIN
		SET @customer_name = NULL;
	END

	IF(@email is null or @email ='')
	BEGIN
		SET @email = NULL;
	END

	IF(@gender is null or @gender ='')
	BEGIN
		SET @gender = NULL;
	END

	IF(@customer_id = 0)
	BEGIN
		SET @customer_id = NULL;
	END

	IF(@wid is null or @wid ='')
	BEGIN
		SET @wid = NULL;
	END

	IF (@from_date is null or @from_date = '')
	BEGIN
		SET @from_date = NULL;
	END

	IF (@to_date is null or @to_date = '')
	BEGIN
		SET @to_date = NULL;
	END

	IF (@ip_address is null or @ip_address ='')
	BEGIN
		set @ip_address = NULL;
	END

	IF(@report is null or @report ='')
	BEGIN
		SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS no,
		T.campaignName, T.[url],
		c.WID as wid, c.gender,(select floor(datediff(day,c.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,
		T.created_at
		from (

			--Full Page
			SELECT app.name as campaignName,fp.created_at,fp.ip_address,fp.customer_id as customer_id, fp.[url]
			FROM popup_ads_tracker as fp
			join popup_ads_app as app
			on fp.url_id = app.id

			union

			--Catfish
			select app.name as campaignName, catfish.created_at,catfish.ip_address, catfish.customer_id as customer_id, catfish.[url]
			from footer_ads_tracker as catfish
			join footer_ads_app as app
			on catfish.url_id = app.id

			union

			--Scans Pop-up
			select cam.campaign_name as campaignName, qr.created_at,qr.ip_address, qr.customer_id, qr.[url]  
			from qrscan_popup_ads_tracker as qr
			join campaign_small_image as img
			on qr.url_id = img.id
			join campaign as cam
			on cam.campaign_id = img.campaign_id

			union

			--WINK GO Pop-up
			select cam.campaign_name as campaignName, winkGo.created_at,winkGo.ip_address, winkGo.customer_id, winkGo.[url]  
			from winkgo_ads_tracker as winkGo
			join campaign as cam
			on cam.campaign_id = winkGo.url_id

			union

			--Large Banner
			select cam.campaign_name as campaignName, large.created_at,large.ip_address, large.customer_id, large.[url]
			from largebanner_ads_tracker as large
			join campaign_large_image as img
			on large.url_id = img.id
			join campaign as cam
			on cam.campaign_id = img.campaign_id

			union

			--WINK+ Play
			select cam.campaign_name as campaignName, winkplay.created_at,winkplay.ip_address, winkplay.customer_id, winkplay.[url]
			from winktag_ads_tracker as winkplay
			join winktag_campaign as cam
			on winkplay.url_id = cam.campaign_id

			union

			--TransitLink
			select os as campaignName, created_at, ip_address, '' as customer_id, tl.[url]
			from transitlink_app_tracker as tl

			union

			--SMRTConnect
			select os as campaignName, created_at, ip_address, '' as customer_id, sc.[url]
			from smrtconnect_app_tracker as sc

			union

			--WINK+ Site
			select [source] as campaignName, created_at, ip_address, '' as customer_id, m.[url]
			from microsite_ads_tracker as m WHERE [source] not like 'Deep Link:%'

			union

			--Deep Link
			select [source] as campaignName, created_at, ip_address, customer_id, m.[url]
			from microsite_ads_tracker as m WHERE [source] like 'Deep Link:%'

			union

			--Push Notification
			select cam.campaign_name as campaignName, push.created_at,push.ip_address, push.customer_id, '' as [url]
			from push_ads_tracker as push
			join winktag_campaign as cam
			on push.campaign_id = cam.campaign_id
			where push.campaign_id!=0
			
			union 
			select 
				CASE 
					WHEN LEN(push.[type]) > 0 THEN push.[type] 
					ELSE COALESCE('Push Notification', '') 
				END as campaignName, 
			push.created_at,push.ip_address, push.customer_id, '' as [url]
			from push_ads_tracker as push
			where push.campaign_id = 0

			union

			--Promo Banner
			SELECT app.[banner_name] as campaignName,pb.created_at,pb.ip_address,pb.customer_id as customer_id, pb.[url]
			FROM promo_banner_ads_tracker as pb
			join promo_banner_ads_app as app
			on pb.url_id = app.id			
				
		) as T

		left join 
		customer as c
		on c.customer_id = T.customer_id
		where (@campaignName is null or T.campaignName like '%'+@campaignName+'%')
		and (@url is null or T.[url] like '%'+@url+'%')
		and (@customer_name is null or (c.first_name+' '+ c.last_name) like '%'+@customer_name+'%')
		and (@customer_id is null or T.customer_id =@customer_id)
		and (@gender is null or c.gender = @gender)
		and (@wid is null or c.wid like '%'+@wid+'%')
		and (@email is null or c.email like '%'+@email+'%')
		and (@ip_address is null or T.ip_address like '%'+@ip_address+'%')
		and (@from_date IS NULL OR CAST(T.created_at as Date) BETWEEN CAST(@from_date as Date) AND CAST(@to_date as Date))
		order by T.created_at desc
	END
	ELSE IF(@report = 'fullpage')
	BEGIN
		SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS no,
		T.campaignName, T.[url],
		c.WID as wid, c.gender,(select floor(datediff(day,c.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,
		T.created_at
		from (

			--Full Page
			SELECT app.name as campaignName,fp.created_at,fp.ip_address,fp.customer_id as customer_id, fp.[url]
			FROM popup_ads_tracker as fp
			join popup_ads_app as app
			on fp.url_id = app.id
				
		) as T

		left join 
		customer as c
		on c.customer_id = T.customer_id
		where (@campaignName is null or T.campaignName like '%'+@campaignName+'%')
		and (@url is null or T.[url] like '%'+@url+'%')
		and (@customer_name is null or (c.first_name+' '+ c.last_name) like '%'+@customer_name+'%')
		and (@customer_id is null or T.customer_id =@customer_id)
		and (@gender is null or c.gender = @gender)
		and (@wid is null or c.wid like '%'+@wid+'%')
		and (@email is null or c.email like '%'+@email+'%')
		and (@ip_address is null or T.ip_address like '%'+@ip_address+'%')
		and (@from_date IS NULL OR CAST(T.created_at as Date) BETWEEN CAST(@from_date as Date) AND CAST(@to_date as Date))
		order by T.created_at desc
	END
	ELSE IF(@report = 'catfish')
	BEGIN
		SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS no,
		T.campaignName, T.[url],
		c.WID as wid, c.gender,(select floor(datediff(day,c.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,
		T.created_at
		from (

			--Catfish
			select app.name as campaignName, catfish.created_at,catfish.ip_address, catfish.customer_id as customer_id, catfish.[url]
			from footer_ads_tracker as catfish
			join footer_ads_app as app
			on catfish.url_id = app.id
				
		) as T

		left join 
		customer as c
		on c.customer_id = T.customer_id
		where (@campaignName is null or T.campaignName like '%'+@campaignName+'%')
		and (@url is null or T.[url] like '%'+@url+'%')
		and (@customer_name is null or (c.first_name+' '+ c.last_name) like '%'+@customer_name+'%')
		and (@customer_id is null or T.customer_id =@customer_id)
		and (@gender is null or c.gender = @gender)
		and (@wid is null or c.wid like '%'+@wid+'%')
		and (@email is null or c.email like '%'+@email+'%')
		and (@ip_address is null or T.ip_address like '%'+@ip_address+'%')
		and (@from_date IS NULL OR CAST(T.created_at as Date) BETWEEN CAST(@from_date as Date) AND CAST(@to_date as Date))
		order by T.created_at desc
	END
	ELSE IF(@report = 'scans')
	BEGIN
		SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS no,
		T.campaignName, T.[url],
		c.WID as wid, c.gender,(select floor(datediff(day,c.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,
		T.created_at
		from (

			--Scans Pop-up
			select cam.campaign_name as campaignName, qr.created_at,qr.ip_address, qr.customer_id, qr.[url]  
			from qrscan_popup_ads_tracker as qr
			join campaign_small_image as img
			on qr.url_id = img.id
			join campaign as cam
			on cam.campaign_id = img.campaign_id
				
		) as T

		left join 
		customer as c
		on c.customer_id = T.customer_id
		where (@campaignName is null or T.campaignName like '%'+@campaignName+'%')
		and (@url is null or T.[url] like '%'+@url+'%')
		and (@customer_name is null or (c.first_name+' '+ c.last_name) like '%'+@customer_name+'%')
		and (@customer_id is null or T.customer_id =@customer_id)
		and (@gender is null or c.gender = @gender)
		and (@wid is null or c.wid like '%'+@wid+'%')
		and (@email is null or c.email like '%'+@email+'%')
		and (@ip_address is null or T.ip_address like '%'+@ip_address+'%')
		and (@from_date IS NULL OR CAST(T.created_at as Date) BETWEEN CAST(@from_date as Date) AND CAST(@to_date as Date))
		order by T.created_at desc
	END
	ELSE IF(@report = 'winkGo')
	BEGIN
		SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS no,
		T.campaignName, T.[url],
		c.WID as wid, c.gender,(select floor(datediff(day,c.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,
		T.created_at
		from (

			--WINK GO Pop-up
			select cam.campaign_name as campaignName, winkGo.created_at,winkGo.ip_address, winkGo.customer_id, winkGo.[url]  
			from winkgo_ads_tracker as winkGo
			join campaign as cam
			on cam.campaign_id = winkGo.url_id
				
		) as T

		left join 
		customer as c
		on c.customer_id = T.customer_id
		where (@campaignName is null or T.campaignName like '%'+@campaignName+'%')
		and (@url is null or T.[url] like '%'+@url+'%')
		and (@customer_name is null or (c.first_name+' '+ c.last_name) like '%'+@customer_name+'%')
		and (@customer_id is null or T.customer_id =@customer_id)
		and (@gender is null or c.gender = @gender)
		and (@wid is null or c.wid like '%'+@wid+'%')
		and (@email is null or c.email like '%'+@email+'%')
		and (@ip_address is null or T.ip_address like '%'+@ip_address+'%')
		and (@from_date IS NULL OR CAST(T.created_at as Date) BETWEEN CAST(@from_date as Date) AND CAST(@to_date as Date))
		order by T.created_at desc
	END
	ELSE IF(@report = 'large')
	BEGIN
		SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS no,
		T.campaignName, T.[url],
		c.WID as wid, c.gender,(select floor(datediff(day,c.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,
		T.created_at
		from (

			--Large Banner
			select cam.campaign_name as campaignName, large.created_at,large.ip_address, large.customer_id, large.[url]
			from largebanner_ads_tracker as large
			join campaign_large_image as img
			on large.url_id = img.id
			join campaign as cam
			on cam.campaign_id = img.campaign_id
				
		) as T

		left join 
		customer as c
		on c.customer_id = T.customer_id
		where (@campaignName is null or T.campaignName like '%'+@campaignName+'%')
		and (@url is null or T.[url] like '%'+@url+'%')
		and (@customer_name is null or (c.first_name+' '+ c.last_name) like '%'+@customer_name+'%')
		and (@customer_id is null or T.customer_id =@customer_id)
		and (@gender is null or c.gender = @gender)
		and (@wid is null or c.wid like '%'+@wid+'%')
		and (@email is null or c.email like '%'+@email+'%')
		and (@ip_address is null or T.ip_address like '%'+@ip_address+'%')
		and (@from_date IS NULL OR CAST(T.created_at as Date) BETWEEN CAST(@from_date as Date) AND CAST(@to_date as Date))
		order by T.created_at desc
	END
	ELSE IF(@report = 'winkplay')
	BEGIN
		SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS no,
		T.campaignName, T.[url],
		c.WID as wid, c.gender,(select floor(datediff(day,c.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,
		T.created_at
		from (

			--WINK+ Play
			select cam.campaign_name as campaignName, winkplay.created_at,winkplay.ip_address, winkplay.customer_id, winkplay.[url]
			from winktag_ads_tracker as winkplay
			join winktag_campaign as cam
			on winkplay.url_id = cam.campaign_id
				
		) as T

		left join 
		customer as c
		on c.customer_id = T.customer_id
		where (@campaignName is null or T.campaignName like '%'+@campaignName+'%')
		and (@url is null or T.[url] like '%'+@url+'%')
		and (@customer_name is null or (c.first_name+' '+ c.last_name) like '%'+@customer_name+'%')
		and (@customer_id is null or T.customer_id =@customer_id)
		and (@gender is null or c.gender = @gender)
		and (@wid is null or c.wid like '%'+@wid+'%')
		and (@email is null or c.email like '%'+@email+'%')
		and (@ip_address is null or T.ip_address like '%'+@ip_address+'%')
		and (@from_date IS NULL OR CAST(T.created_at as Date) BETWEEN CAST(@from_date as Date) AND CAST(@to_date as Date))
		order by T.created_at desc
	END
	ELSE IF(@report = 'transitlink')
	BEGIN
		SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS no,
		T.campaignName, T.[url],
		c.WID as wid, c.gender,(select floor(datediff(day,c.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,
		T.created_at
		from (

			--SMRTConnect
			select os as campaignName, created_at, ip_address, '' as customer_id, tl.[url]
			from transitlink_app_tracker as tl
				
		) as T

		left join 
		customer as c
		on c.customer_id = T.customer_id
		where (@campaignName is null or T.campaignName like '%'+@campaignName+'%')
		and (@url is null or T.[url] like '%'+@url+'%')
		and (@customer_name is null or (c.first_name+' '+ c.last_name) like '%'+@customer_name+'%')
		and (@customer_id is null or T.customer_id =@customer_id)
		and (@gender is null or c.gender = @gender)
		and (@wid is null or c.wid like '%'+@wid+'%')
		and (@email is null or c.email like '%'+@email+'%')
		and (@ip_address is null or T.ip_address like '%'+@ip_address+'%')
		and (@from_date IS NULL OR CAST(T.created_at as Date) BETWEEN CAST(@from_date as Date) AND CAST(@to_date as Date))
		order by T.created_at desc
	END
	ELSE IF(@report = 'winksite')
	BEGIN
		SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS no,
		T.campaignName, T.[url],
		c.WID as wid, c.gender,(select floor(datediff(day,c.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,
		T.created_at
		from (

			--WINK+ Site
			select source as campaignName, created_at, ip_address, '' as customer_id, m.[url]
			from microsite_ads_tracker as m WHERE [source] not like 'Deep Link:%'
				
		) as T

		left join 
		customer as c
		on c.customer_id = T.customer_id
		where (@campaignName is null or T.campaignName like '%'+@campaignName+'%')
		and (@url is null or T.[url] like '%'+@url+'%')
		and (@customer_name is null or (c.first_name+' '+ c.last_name) like '%'+@customer_name+'%')
		and (@customer_id is null or T.customer_id =@customer_id)
		and (@gender is null or c.gender = @gender)
		and (@wid is null or c.wid like '%'+@wid+'%')
		and (@email is null or c.email like '%'+@email+'%')
		and (@ip_address is null or T.ip_address like '%'+@ip_address+'%')
		and (@from_date IS NULL OR CAST(T.created_at as Date) BETWEEN CAST(@from_date as Date) AND CAST(@to_date as Date))
		order by T.created_at desc
	END
	ELSE IF(@report = 'deeplink')
	BEGIN
		SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS no,
		T.campaignName, T.[url],
		c.WID as wid, c.gender,(select floor(datediff(day,c.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,
		T.created_at
		from (

			--Deep Link
			select [source] as campaignName, created_at, ip_address, customer_id, m.[url]
			from microsite_ads_tracker as m WHERE [source] like 'Deep Link:%'
				
		) as T

		left join 
		customer as c
		on c.customer_id = T.customer_id
		where (@campaignName is null or T.campaignName like '%'+@campaignName+'%')
		and (@url is null or T.[url] like '%'+@url+'%')
		and (@customer_name is null or (c.first_name+' '+ c.last_name) like '%'+@customer_name+'%')
		and (@customer_id is null or T.customer_id =@customer_id)
		and (@gender is null or c.gender = @gender)
		and (@wid is null or c.wid like '%'+@wid+'%')
		and (@email is null or c.email like '%'+@email+'%')
		and (@ip_address is null or T.ip_address like '%'+@ip_address+'%')
		and (@from_date IS NULL OR CAST(T.created_at as Date) BETWEEN CAST(@from_date as Date) AND CAST(@to_date as Date))
		order by T.created_at desc
	END
	ELSE IF(@report = 'push')
	BEGIN
		SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS no,
		T.campaignName, T.[url],
		c.WID as wid, c.gender,(select floor(datediff(day,c.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,
		T.created_at
		from (

			--Push Notification
			select cam.campaign_name as campaignName, push.created_at,push.ip_address, push.customer_id, '' as [url]
			from push_ads_tracker as push
			join winktag_campaign as cam
			on push.campaign_id = cam.campaign_id
			where push.campaign_id!=0
			
			union 
			select CASE 
					WHEN LEN(push.[type]) > 0 THEN push.[type] 
					ELSE COALESCE('Push Notification', '') 
				END as campaignName, 
			push.created_at,push.ip_address, push.customer_id, '' as [url]
			from push_ads_tracker as push
			where push.campaign_id = 0
				
		) as T

		left join 
		customer as c
		on c.customer_id = T.customer_id
		where (@campaignName is null or T.campaignName like '%'+@campaignName+'%')
		and (@url is null or [url] like '%'+@url+'%')
		and (@customer_name is null or (c.first_name+' '+ c.last_name) like '%'+@customer_name+'%')
		and (@customer_id is null or T.customer_id =@customer_id)
		and (@gender is null or c.gender = @gender)
		and (@wid is null or c.wid like '%'+@wid+'%')
		and (@email is null or c.email like '%'+@email+'%')
		and (@ip_address is null or T.ip_address like '%'+@ip_address+'%')
		and (@from_date IS NULL OR CAST(T.created_at as Date) BETWEEN CAST(@from_date as Date) AND CAST(@to_date as Date))
		order by T.created_at desc
	END
	ELSE IF(@report = 'smrtconnect')
	BEGIN
		SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS no,
		T.campaignName, T.[url],
		c.WID as wid, c.gender,(select floor(datediff(day,c.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,
		T.created_at
		from (

			--SMRTConnect
			select os as campaignName, created_at, ip_address, '' as customer_id, sc.[url]
			from smrtconnect_app_tracker as sc
				
		) as T

		left join 
		customer as c
		on c.customer_id = T.customer_id
		where (@campaignName is null or T.campaignName like '%'+@campaignName+'%')
		and (@url is null or T.[url] like '%'+@url+'%')
		and (@customer_name is null or (c.first_name+' '+ c.last_name) like '%'+@customer_name+'%')
		and (@customer_id is null or T.customer_id =@customer_id)
		and (@gender is null or c.gender = @gender)
		and (@wid is null or c.wid like '%'+@wid+'%')
		and (@email is null or c.email like '%'+@email+'%')
		and (@ip_address is null or T.ip_address like '%'+@ip_address+'%')
		and (@from_date IS NULL OR CAST(T.created_at as Date) BETWEEN CAST(@from_date as Date) AND CAST(@to_date as Date))
		order by T.created_at desc
	END
	ELSE IF(@report = 'promobanner')
	BEGIN
		SELECT ROW_NUMBER() OVER (Order by T.CREATED_AT ASC)AS no,
		T.campaignName, T.[url],
		c.WID as wid, c.gender,(select floor(datediff(day,c.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,
		T.created_at
		from (

			--Promo Banner
			SELECT app.[banner_name] as campaignName,pb.created_at,pb.ip_address,pb.customer_id as customer_id, pb.[url]
			FROM promo_banner_ads_tracker as pb
			join promo_banner_ads_app as app
			on pb.url_id = app.id
				
		) as T

		left join 
		customer as c
		on c.customer_id = T.customer_id
		where (@campaignName is null or T.campaignName like '%'+@campaignName+'%')
		and (@url is null or T.[url] like '%'+@url+'%')
		and (@customer_name is null or (c.first_name+' '+ c.last_name) like '%'+@customer_name+'%')
		and (@customer_id is null or T.customer_id =@customer_id)
		and (@gender is null or c.gender = @gender)
		and (@wid is null or c.wid like '%'+@wid+'%')
		and (@email is null or c.email like '%'+@email+'%')
		and (@ip_address is null or T.ip_address like '%'+@ip_address+'%')
		and (@from_date IS NULL OR CAST(T.created_at as Date) BETWEEN CAST(@from_date as Date) AND CAST(@to_date as Date))
		order by T.created_at desc
	END
END

