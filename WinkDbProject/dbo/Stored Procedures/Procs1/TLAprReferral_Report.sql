CREATE PROC [dbo].[TLAprReferral_Report]
(
	@refereeWid varchar(50),
	@refereeCid int,
	@refereeName varchar(200),
	@refereeEmail varchar(200),
	@refereeGender varchar(200),
	@refereeStatus varchar(50),
	@bankType varchar(3),
	@referrerWid varchar(50),
	@referrerCid int,
	@referrerName varchar(200),
	@referrerEmail varchar(200),
	@start_date varchar(50),
	@end_date varchar(50),
	@winktag_report varchar(50)
)
AS

BEGIN

	DECLARE @CAMPAIGN_ID int;
	
	IF(@refereeWid is null or @refereeWid ='')
		SET @refereeWid = NULL
	
	IF(@refereeCid = 0)
		SET @refereeCid = NULL

	IF(@refereeName is null or @refereeName ='')
		SET @refereeName = NULL

	IF(@refereeEmail is null or @refereeEmail ='')
		SET @refereeEmail = NULL

	IF(@refereeGender is null or @refereeGender ='')
		SET @refereeGender = NULL

	IF(@refereeStatus is null or @refereeStatus='')
		SET @refereeStatus = NULL
	
	IF(@bankType is null or @bankType='')
		SET @bankType = NULL

	IF(@referrerWid is null or @referrerWid ='')
		SET @referrerWid = NULL
	
	IF(@referrerCid = 0)
		SET @referrerCid = NULL

	IF(@referrerName is null or @referrerName ='')
		SET @referrerName = NULL

	IF(@referrerEmail is null or @referrerEmail ='')
		SET @referrerEmail = NULL

	IF (@start_date is null or @start_date = '')
		SET @start_date = NULL;

	IF (@end_date is null or @end_date = '')
		SET @end_date = NULL;

	
	IF NOT EXISTS(SELECT * FROM winktag_campaign WHERE winktag_report = @winktag_report)
		RETURN;
	ELSE
		SET @CAMPAIGN_ID = (SELECT CAMPAIGN_ID FROM winktag_campaign WHERE winktag_report = @winktag_report)

	IF( @CAMPAIGN_ID = 162)
	BEGIN
		SELECT * FROM 
		(--1 START
			SELECT ROW_NUMBER() OVER (Order by T.createdOn ASC)AS [no], T.*,
			Customer.WID as refereeWid, CUSTOMER.first_name +' '+CUSTOMER.last_name as refereeName,
			CUSTOMER.email as refereeEmail,CUSTOMER.gender, 
			(select floor(datediff(day,CUSTOMER.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25)) as age,
			Customer.[status] as [status]
			FROM
			(
				-----table1
				SELECT refereeCid, refereePts, [location], [ip], referralCode, referrerWid, referrerCid, referrerName,
				referrerEmail, referrerPts, createdOn
				FROM wink_thirdparty_referral
				WHERE campaignId = @CAMPAIGN_ID

			) AS T 
			INNER JOIN CUSTOMER ON T.refereeCid = CUSTOMER.customer_id 
			WHERE (@bankType is null
				or T.referralCode like (@bankType+'%')
			)		
		) AS TEMP----1 END
		WHERE (@refereeWid is null or TEMP.refereeWid like '%'+@refereeWid+'%')
		AND (@refereeCid is null or TEMP.refereeCid = @refereeCid)
		AND (@refereeName is null or TEMP.refereeName like '%'+@refereeName+'%') 
		AND (@refereeEmail is null or TEMP.refereeEmail like '%'+@refereeEmail+'%')
		AND (@refereeGender is null or TEMP.gender = @refereeGender)
		AND  (@referrerWid is null or TEMP.referrerWid like '%'+@referrerWid+'%')
		AND (@referrerCid is null or TEMP.referrerCid = @referrerCid)
		AND (@referrerName is null or TEMP.referrerName like '%'+@referrerName+'%') 
		AND (@referrerEmail is null or TEMP.referrerEmail like '%'+@referrerEmail+'%')
		AND (@refereeStatus is null or TEMP.[status] = @refereeStatus)
		AND (@start_date IS NULL OR CAST(TEMP.createdOn as Date) BETWEEN CAST(@start_date as Date) AND CAST(@end_date as Date))
			 
		order by temp.no desc
	END

END



