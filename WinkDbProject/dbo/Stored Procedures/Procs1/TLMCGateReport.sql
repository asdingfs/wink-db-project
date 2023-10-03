
CREATE PROCEDURE [dbo].[TLMCGateReport]
(
	@wid varchar(50),
	@customer_id int,
	@name varchar(100),
	@email varchar(100),
	@gender varchar(10),
	@gateId varchar(100),
	@cardType varchar(10),
	--@winner varchar(10),
	--@isLuckyDraw varchar(10),
	@ip_address varchar(50),
	@location varchar(255),
	@status varchar(50),
	@start_date datetime,
	@end_date datetime,
	@intPage int,
    @intPageSize int
)
AS
BEGIN

	DECLARE @intStartRow int;
	DECLARE @intEndRow int;

	Declare @current_datetime datetime

	Exec GET_CURRENT_SINGAPORT_DATETIME @current_datetime output

	
	SET @intStartRow = (@intPage -1) * @intPageSize + 1;
	SET @intEndRow = @intPage * @intPageSize;

	DECLARE @TLMCSilverCampaignId int = 44;
	DECLARE @TLMCGoldenCampaignId int = 45;

	--DECLARE @TLMCSapphireCampaignId int = 43;
	--DECLARE @TLMCSapphireWinnerEntry int = 28;

	--DECLARE @TLMCDiamondCampaignId int = 46;
	--DECLARE @TLMCDiamondWinnerEntry int = 29;

	IF(@customer_id = 0)
	BEGIN
		SET @customer_id = NULL;
	END

	IF(@wid is null or @wid ='')
	BEGIN
		SET @wid = NULL;
	END
	IF (@start_date is null or @start_date = '')
	BEGIN
		SET @start_date = NULL;
	END

	IF (@end_date is null or @end_date = '')
	BEGIN
		SET @end_date = NULL;
	END

	IF (@email is null or @email = '')
	BEGIN
		SET @email = NULL;
	END
	ELSE
	BEGIN
		SET @email = LTRIM(RTRIM(@email));
	END
 
	IF (@name is null or @name = '')
	BEGIN
		SET @name = NULL;
	END
	ELSE
	BEGIN
		SET @name = LTRIM(RTRIM(@name));
	END

	 IF (@gateId is null or @gateId = '')
	 BEGIN
		SET @gateId = NULL;
	 END
	 ELSE
	 BEGIN
		SET @gateId = LTRIM(RTRIM(@gateId));
	 END
	IF(@cardType is null or @cardType='')
	BEGIN
		SET @cardType = NULL
	END

	--IF(@winner is null or @winner='')
	--BEGIN
	--	SET @winner = NULL;
	--END
	--IF(@isLuckyDraw is null or @isLuckyDraw ='')
	--BEGIN
	--	SET @isLuckyDraw = NULL;
	--END
	IF (@ip_address is null or @ip_address = '')
	BEGIN
		SET @ip_address = NULL;
	END
	ELSE
	BEGIN
		SET @ip_address = LTRIM(RTRIM(@ip_address));
	END

	IF (@gender is null or @gender = '')
	BEGIN
		SET @gender = NULL;
	END

	IF (@location is null or @location = '')
	BEGIN
		SET @location = NULL;
	END
	ELSE
	BEGIN
		SET @location = LTRIM(RTRIM(@location));
	END

	IF (@status is null or @status = '')
	BEGIN
		SET @status = NULL;
	END 
	SELECT * FROM 
	(
		SELECT c.WID as wid, c.gender,
		(CONVERT(int,CONVERT(char(8),@current_datetime,112))-CONVERT(char(8),Cast(c.date_of_birth as date),112))/10000 AS age,
		a.gate_id as gateId, 
		cusCard.cardType,
		e.points As points,
		c.[status] as customer_status, e.created_at as createdAt, 
		datepart(HOUR,e.created_at)as created_hour,
		ROW_NUMBER() OVER(
			ORDER BY e.customer_id DESC, e.created_at DESC)
		as id,
		COUNT(*) OVER() as total_count
		FROM wink_gate_points_earned as e
		JOIN customer as c
		ON e.customer_id = c.customer_id
		JOIN wink_gate_asset as a
		ON e.assetId = a.id
		JOIN wink_gate_booking as b
		ON e.bookingId = b.id
		LEFT JOIN customer_card_types as cusCard
		ON cusCard.customerId = c.customer_id
		WHERE (b.wink_gate_campaign_id = @TLMCSilverCampaignId
			or b.wink_gate_campaign_id = @TLMCGoldenCampaignId)
		AND b.[status] = 1
		AND (@cardType is null or (cusCard.cardType = @cardType))
		AND (@wid is null or c.wid like '%'+@wid+'%')
		AND (@customer_id is null or c.customer_id = @customer_id)
		AND (@name IS NULL OR c.first_name + ' ' + c.last_name like '%'+ Lower(@name) +'%')
		AND (@email IS NULL OR c.email like '%'+ @email + '%')
		AND (@gender IS NULL OR c.gender = @gender )
		AND (@gateId IS NULL OR a.gate_id like '%' + @gateId + '%') 
		AND (@location IS NULL OR e.GPS_location like '%' + @location + '%')
		AND (@ip_address IS NULL OR e.ip_address like '%' + @ip_address + '%')
		AND (@status IS NULL OR c.[status] like '%' + @status + '%')
		AND (@start_date IS NULL OR CAST(e.created_at as Date) BETWEEN @start_date AND @end_date) 
	) as w
	WHERE w.id between @intStartRow and @intEndRow
	ORDER BY w.createdAt DESC
	--IF(@winner IS NULL)
	--BEGIN
	--	SELECT * FROM 
	--	(
	--		SELECT c.WID as wid, c.gender,
	--		(CONVERT(int,CONVERT(char(8),@current_datetime,112))-CONVERT(char(8),Cast(c.date_of_birth as date),112))/10000 AS age,
	--		a.gate_id as gateId, 
	--		CASE WHEN (
	--			b.wink_gate_campaign_id = @TLMCSapphireCampaignId 
	--			or b.wink_gate_campaign_id = @TLMCDiamondCampaignId
	--		)
	--		THEN(
	--			CASE WHEN EXISTS (
	--				SELECT 1 
	--				from wink_gate_points_earned as we
	--				left join winners_points as ww
	--				on we.id = ww.[location]
	--				WHERE (ww.entry_id = @TLMCSapphireWinnerEntry or  ww.entry_id = @TLMCDiamondWinnerEntry) 
	--				AND we.id = e.id
	--			) THEN 'Yes'
	--			ELSE 'No' END
	--		)
	--		ELSE 'NA' END 
	--		AS winner, 
	--		cusCard.cardType,
	--		e.points As points,
	--		c.[status] as customer_status, e.created_at as createdAt, 
	--		datepart(HOUR,e.created_at)as created_hour,
	--		ROW_NUMBER() OVER(
	--			ORDER BY e.customer_id DESC, e.created_at DESC)
	--		as id,
	--		COUNT(*) OVER() as total_count
	--		FROM wink_gate_points_earned as e
	--		JOIN customer as c
	--		ON e.customer_id = c.customer_id
	--		JOIN wink_gate_asset as a
	--		ON e.assetId = a.id
	--		JOIN wink_gate_booking as b
	--		ON e.bookingId = b.id
	--		LEFT JOIN customer_card_types as cusCard
	--		ON cusCard.customerId = c.customer_id
	--		WHERE (
	--			b.wink_gate_campaign_id = @TLMCSilverCampaignId
	--			or b.wink_gate_campaign_id = @TLMCGoldenCampaignId
	--			or b.wink_gate_campaign_id = @TLMCSapphireCampaignId
	--			or b.wink_gate_campaign_id = @TLMCDiamondCampaignId
	--		)
	--		AND (@isLuckyDraw is null 
	--			OR (@isLuckyDraw = '1' AND (b.wink_gate_campaign_id = @TLMCSapphireCampaignId
	--											or b.wink_gate_campaign_id = @TLMCDiamondCampaignId)
	--				)
	--			OR (@isLuckyDraw = '0' AND (b.wink_gate_campaign_id = @TLMCSilverCampaignId
	--											or b.wink_gate_campaign_id = @TLMCGoldenCampaignId)
	--				)
	--		)
	--		AND (@cardType is null or (cusCard.cardType = @cardType))
	--		AND b.[status] = 1
	--		AND (@wid is null or c.wid like '%'+@wid+'%')
	--		AND (@customer_id is null or c.customer_id = @customer_id)
	--		AND (@name IS NULL OR c.first_name + ' ' + c.last_name like '%'+ Lower(@name) +'%')
	--		AND (@email IS NULL OR c.email like '%'+ @email + '%')
	--		AND (@gender IS NULL OR c.gender = @gender )
	--		AND (@gateId IS NULL OR a.gate_id like '%' + @gateId + '%') 
	--		AND (@location IS NULL OR e.GPS_location like '%' + @location + '%')
	--		AND (@ip_address IS NULL OR e.ip_address like '%' + @ip_address + '%')
	--		AND (@status IS NULL OR c.[status] like '%' + @status + '%')
	--		AND (@start_date IS NULL OR CAST(e.created_at as Date) BETWEEN @start_date AND @end_date) 
	--	) as w
	--	WHERE w.id between @intStartRow and @intEndRow
	--	ORDER BY w.createdAt DESC
	--END
	--ELSE IF(@winner like '1')
	--BEGIN
	--	SELECT * FROM 
	--	(
	--		SELECT c.WID as wid, c.gender,
	--		(CONVERT(int,CONVERT(char(8),@current_datetime,112))-CONVERT(char(8),Cast(c.date_of_birth as date),112))/10000 AS age,
	--		a.gate_id as gateId, 
	--		'Yes' AS winner, 
	--		cusCard.cardType,
	--		e.points As points,
	--		c.[status] as customer_status, e.created_at as createdAt, 
	--		datepart(HOUR,e.created_at)as created_hour,
	--		ROW_NUMBER() OVER(
	--			ORDER BY e.customer_id DESC, e.created_at DESC)
	--		as id,
	--		COUNT(*) OVER() as total_count
	--		FROM wink_gate_points_earned as e
	--		JOIN customer as c
	--		ON e.customer_id = c.customer_id
	--		JOIN wink_gate_asset as a
	--		ON e.assetId = a.id
	--		LEFT JOIN winners_points as w
	--		ON w.[location] = e.id
	--		JOIN wink_gate_booking as b
	--		ON e.bookingId = b.id
	--		LEFT JOIN customer_card_types as cusCard
	--		ON cusCard.customerId = c.customer_id

	--		WHERE (b.wink_gate_campaign_id = @TLMCSapphireCampaignId
	--			or b.wink_gate_campaign_id = @TLMCDiamondCampaignId)
	--		AND b.[status] = 1
	--		AND (w.entry_id = @TLMCSapphireWinnerEntry or  w.entry_id = @TLMCDiamondWinnerEntry) 
	--		AND (@isLuckyDraw is null 
	--			OR (@isLuckyDraw = '1' AND (b.wink_gate_campaign_id = @TLMCSapphireCampaignId
	--											or b.wink_gate_campaign_id = @TLMCDiamondCampaignId)
	--				)
	--			OR (@isLuckyDraw = '0' AND (b.wink_gate_campaign_id = @TLMCSilverCampaignId
	--											or b.wink_gate_campaign_id = @TLMCGoldenCampaignId)
	--				)
	--		)
	--		AND (@cardType is null or (cusCard.cardType = @cardType))
	--		AND (@wid is null or c.wid like '%'+@wid+'%')
	--		AND (@customer_id is null or c.customer_id = @customer_id)
	--		AND (@name IS NULL OR c.first_name + ' ' + c.last_name like '%'+ Lower(@name) +'%')
	--		AND (@email IS NULL OR c.email like '%'+ @email + '%')
	--		AND (@gender IS NULL OR c.gender = @gender )
	--		AND (@gateId IS NULL OR a.gate_id like '%' + @gateId + '%') 
	--		AND (@location IS NULL OR e.GPS_location like '%' + @location + '%')
	--		AND (@ip_address IS NULL OR e.ip_address like '%' + @ip_address + '%')
	--		AND (@status IS NULL OR c.[status] like '%' + @status + '%')
	--		AND (@start_date IS NULL OR CAST(e.created_at as Date) BETWEEN @start_date AND @end_date) 
	--	) as w
	--	WHERE w.id between @intStartRow and @intEndRow
	--	ORDER BY w.createdAt DESC
	--END
	--ELSE IF(@winner like '0')
	--BEGIN
	--	SELECT * FROM 
	--	(
	--		SELECT c.WID as wid, c.gender,
	--		(CONVERT(int,CONVERT(char(8),@current_datetime,112))-CONVERT(char(8),Cast(c.date_of_birth as date),112))/10000 AS age,
	--		a.gate_id as gateId, 
	--		'No' AS winner, 
	--		cusCard.cardType,
	--		e.points As points,
	--		c.[status] as customer_status, e.created_at as createdAt, 
	--		datepart(HOUR,e.created_at)as created_hour,
	--		ROW_NUMBER() OVER(
	--			ORDER BY e.customer_id DESC, e.created_at DESC)
	--		as id,
	--		COUNT(*) OVER() as total_count
	--		FROM wink_gate_points_earned as e
	--		JOIN customer as c
	--		ON e.customer_id = c.customer_id
	--		JOIN wink_gate_asset as a
	--		ON e.assetId = a.id
	--		JOIN wink_gate_booking as b
	--		ON e.bookingId = b.id
	--		LEFT JOIN customer_card_types as cusCard
	--		ON cusCard.customerId = c.customer_id
	--		WHERE (b.wink_gate_campaign_id = @TLMCSapphireCampaignId
	--			or b.wink_gate_campaign_id = @TLMCDiamondCampaignId)
	--		AND b.[status] = 1
	--		AND e.id NOT IN
	--		(
	--			SELECT ww.[location]
	--			FROM winners_points as ww
	--			WHERE (ww.entry_id = @TLMCSapphireWinnerEntry or  ww.entry_id = @TLMCDiamondWinnerEntry) 
	--		)
	--		AND (@isLuckyDraw is null 
	--			OR (@isLuckyDraw = '1' AND (b.wink_gate_campaign_id = @TLMCSapphireCampaignId
	--											or b.wink_gate_campaign_id = @TLMCDiamondCampaignId)
	--				)
	--			OR (@isLuckyDraw = '0' AND (b.wink_gate_campaign_id = @TLMCSilverCampaignId
	--											or b.wink_gate_campaign_id = @TLMCGoldenCampaignId)
	--				)
	--		)
	--		AND (@cardType is null or (cusCard.cardType = @cardType))
	--		AND (@wid is null or c.wid like '%'+@wid+'%')
	--		AND (@customer_id is null or c.customer_id = @customer_id)
	--		AND (@name IS NULL OR c.first_name + ' ' + c.last_name like '%'+ Lower(@name) +'%')
	--		AND (@email IS NULL OR c.email like '%'+ @email + '%')
	--		AND (@gender IS NULL OR c.gender = @gender )
	--		AND (@gateId IS NULL OR a.gate_id like '%' + @gateId + '%') 
	--		AND (@location IS NULL OR e.GPS_location like '%' + @location + '%')
	--		AND (@ip_address IS NULL OR e.ip_address like '%' + @ip_address + '%')
	--		AND (@status IS NULL OR c.[status] like '%' + @status + '%')
	--		AND (@start_date IS NULL OR CAST(e.created_at as Date) BETWEEN @start_date AND @end_date) 
	--	) as w
	--	WHERE w.id between @intStartRow and @intEndRow
	--	ORDER BY w.createdAt DESC
	--END
	--ELSE IF(@winner like 'NA')
	--BEGIN
	--	SELECT * FROM 
	--	(
	--		SELECT c.WID as wid, c.gender,
	--		(CONVERT(int,CONVERT(char(8),@current_datetime,112))-CONVERT(char(8),Cast(c.date_of_birth as date),112))/10000 AS age,
	--		a.gate_id as gateId, 
	--		'NA' AS winner, 
	--		cusCard.cardType,
	--		e.points As points,
	--		c.[status] as customer_status, e.created_at as createdAt, 
	--		datepart(HOUR,e.created_at)as created_hour,
	--		ROW_NUMBER() OVER(
	--			ORDER BY e.customer_id DESC, e.created_at DESC)
	--		as id,
	--		COUNT(*) OVER() as total_count
	--		FROM wink_gate_points_earned as e
	--		JOIN customer as c
	--		ON e.customer_id = c.customer_id
	--		JOIN wink_gate_asset as a
	--		ON e.assetId = a.id
	--		JOIN wink_gate_booking as b
	--		ON e.bookingId = b.id
	--		LEFT JOIN customer_card_types as cusCard
	--		ON cusCard.customerId = c.customer_id
	--		WHERE (b.wink_gate_campaign_id = @TLMCSilverCampaignId
	--			or b.wink_gate_campaign_id = @TLMCGoldenCampaignId)
	--		AND b.[status] = 1
	--		AND (@isLuckyDraw is null 
	--			OR (@isLuckyDraw = '1' AND (b.wink_gate_campaign_id = @TLMCSapphireCampaignId
	--											or b.wink_gate_campaign_id = @TLMCDiamondCampaignId)
	--				)
	--			OR (@isLuckyDraw = '0' AND (b.wink_gate_campaign_id = @TLMCSilverCampaignId
	--											or b.wink_gate_campaign_id = @TLMCGoldenCampaignId)
	--				)
	--		)
	--		AND (@cardType is null or (cusCard.cardType = @cardType))
	--		AND (@wid is null or c.wid like '%'+@wid+'%')
	--		AND (@customer_id is null or c.customer_id = @customer_id)
	--		AND (@name IS NULL OR c.first_name + ' ' + c.last_name like '%'+ Lower(@name) +'%')
	--		AND (@email IS NULL OR c.email like '%'+ @email + '%')
	--		AND (@gender IS NULL OR c.gender = @gender )
	--		AND (@gateId IS NULL OR a.gate_id like '%' + @gateId + '%') 
	--		AND (@location IS NULL OR e.GPS_location like '%' + @location + '%')
	--		AND (@ip_address IS NULL OR e.ip_address like '%' + @ip_address + '%')
	--		AND (@status IS NULL OR c.[status] like '%' + @status + '%')
	--		AND (@start_date IS NULL OR CAST(e.created_at as Date) BETWEEN @start_date AND @end_date) 
	--	) as w
	--	WHERE w.id between @intStartRow and @intEndRow
	--	ORDER BY w.createdAt DESC
	--END
END

