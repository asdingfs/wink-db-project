CREATE PROCEDURE [dbo].[GetCampaignsList]
(
	@status varchar(50),
	@campaign_name varchar(50),
	@advertiser_name varchar(50),
	@campaign_id int = NULL,
	@campaign_code varchar(100) = NULL
)
AS
BEGIN
	set ARITHABORT ON
	DECLARE @CURRENT_DATETIME Datetime ;     
	EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUTPUT 

	IF (@campaign_id = 0)
		set @campaign_id = NULL
	IF @campaign_name = ''
		set @campaign_name = NULL
	IF @advertiser_name = ''
		set @advertiser_name = NULL
	IF @campaign_code = ''
		set @campaign_code = NULL

	IF (@status IS NULL OR @status='' OR @status=' ')
	BEGIN 
		print ('NULL')
		SELECT campaign.campaign_id, campaign.campaign_name, 
		merchant.first_name,merchant.last_name,
		campaign.campaign_code,
		campaign.campaign_amount, campaign.total_winks, campaign.total_winks_amount,  
		wc.total_points as totalPoints,
		campaign.total_wink_confiscated,
		campaign.campaign_start_date, campaign.campaign_end_date,
		campaign.created_at,
		campaign.campaign_status,
		campaign.wink_purchase_only, campaign.wink_purchase_status
		FROM merchant 
		left join campaign
		ON merchant.merchant_id = campaign.merchant_id
		left join wink_gate_campaign as wc
		ON campaign.campaign_id = wc.campaign_id

		WHERE (@campaign_name is null or  Lower(campaign.campaign_name)LIKE Lower('%'+ @campaign_name +'%') )
		AND (@advertiser_name is null or Lower(merchant.first_name + ' ' + merchant.last_name) LIKE Lower('%'+ @advertiser_name +'%') )
		AND (@campaign_id is null or campaign.campaign_id = @campaign_id)
		AND (@campaign_code is null or LOWER(campaign.campaign_code) like  Lower('%'+ @campaign_code +'%'))
		ORDER BY campaign.campaign_id DESC
	END
    ELSE IF (@status ='active')
	BEGIN
		SELECT campaign.campaign_id, campaign.campaign_name, 
		merchant.first_name,merchant.last_name,
		campaign.campaign_code,
		campaign.campaign_amount, campaign.total_winks, campaign.total_winks_amount,  
		wc.total_points as totalPoints,
		campaign.total_wink_confiscated,
		campaign.campaign_start_date, campaign.campaign_end_date,
		campaign.created_at,
		campaign.campaign_status,
		campaign.wink_purchase_only, campaign.wink_purchase_status
        FROM merchant 
		left join campaign
		ON merchant.merchant_id = campaign.merchant_id
		left join wink_gate_campaign as wc
		ON campaign.campaign_id = wc.campaign_id
		WHERE CONVERT(CHAR(10),@CURRENT_DATETIME,111) >= CONVERT(CHAR(10),CAMPAIGN_START_DATE,111) -- start date is less than current date
        AND CONVERT(CHAR(10),@CURRENT_DATETIME,111) <= CONVERT(CHAR(10),campaign_end_date,111) --end date is greater than current date
        AND campaign.wink_purchase_only =0 --purchase 0
        AND campaign.campaign_status ='enable' -- enable
		AND (@campaign_name is null or  Lower(campaign.campaign_name)LIKE Lower('%'+ @campaign_name +'%') )
		AND (@advertiser_name is null or Lower(merchant.first_name + ' ' + merchant.last_name) LIKE Lower('%'+ @advertiser_name +'%') )
		AND (@campaign_id is null or campaign.campaign_id = @campaign_id)
		AND (@campaign_code is null or LOWER(campaign.campaign_code) like  Lower('%'+ @campaign_code +'%'))
        ORDER BY campaign.campaign_id DESC
	END
	ELSE IF (@status ='inactive')
	BEGIN
		SELECT campaign.campaign_id, campaign.campaign_name, 
		merchant.first_name,merchant.last_name,
		campaign.campaign_code,
		campaign.campaign_amount, campaign.total_winks, campaign.total_winks_amount,  
		wc.total_points as totalPoints,
		campaign.total_wink_confiscated,
		campaign.campaign_start_date, campaign.campaign_end_date,
		campaign.created_at,
		campaign.campaign_status,
		campaign.wink_purchase_only, campaign.wink_purchase_status
        FROM merchant 
		left join campaign
		ON merchant.merchant_id = campaign.merchant_id
		left join wink_gate_campaign as wc
		ON campaign.campaign_id = wc.campaign_id
		WHERE CONVERT(CHAR(10),@CURRENT_DATETIME,111) < CONVERT(CHAR(10),CAMPAIGN_START_DATE,111)  -- start date is greater current date
        AND campaign.wink_purchase_only=0
        AND campaign.campaign_status ='enable'
		AND (@campaign_name is null or  Lower(campaign.campaign_name)LIKE Lower('%'+ @campaign_name +'%') )
		AND (@advertiser_name is null or Lower(merchant.first_name + ' ' + merchant.last_name) LIKE Lower('%'+ @advertiser_name +'%') )
		AND (@campaign_id is null or campaign.campaign_id = @campaign_id)
		AND (@campaign_code is null or LOWER(campaign.campaign_code) like  Lower('%'+ @campaign_code +'%'))
        ORDER BY campaign.campaign_id DESC
	END
	ELSE IF (@status ='expired')
	BEGIN
		SELECT campaign.campaign_id, campaign.campaign_name, 
		merchant.first_name,merchant.last_name,
		campaign.campaign_code,
		campaign.campaign_amount, campaign.total_winks, campaign.total_winks_amount,  
		wc.total_points as totalPoints,
		campaign.total_wink_confiscated,
		campaign.campaign_start_date, campaign.campaign_end_date,
		campaign.created_at,
		campaign.campaign_status,
		campaign.wink_purchase_only, campaign.wink_purchase_status
        FROM merchant 
		left join campaign
		ON merchant.merchant_id = campaign.merchant_id
		left join wink_gate_campaign as wc
		ON campaign.campaign_id = wc.campaign_id
		WHERE CONVERT(CHAR(10),@CURRENT_DATETIME,111) > CONVERT(CHAR(10),campaign_end_date,111) -- end date is less than current date
        AND campaign.wink_purchase_only=0
        AND campaign.campaign_status ='enable'
		AND (@campaign_name is null or  Lower(campaign.campaign_name)LIKE Lower('%'+ @campaign_name +'%') )
		AND (@advertiser_name is null or Lower(merchant.first_name + ' ' + merchant.last_name) LIKE Lower('%'+ @advertiser_name +'%') )
		AND (@campaign_id is null or campaign.campaign_id = @campaign_id)
		AND (@campaign_code is null or LOWER(campaign.campaign_code) like  Lower('%'+ @campaign_code +'%'))
        ORDER BY campaign.campaign_id DESC
	END
	ELSE IF (@status='onhold')
	BEGIN
		SELECT campaign.campaign_id, campaign.campaign_name, 
		merchant.first_name,merchant.last_name,
		campaign.campaign_code,
		campaign.campaign_amount, campaign.total_winks, campaign.total_winks_amount,  
		wc.total_points as totalPoints,
		campaign.total_wink_confiscated,
		campaign.campaign_start_date, campaign.campaign_end_date,
		campaign.created_at,
		campaign.campaign_status,
		campaign.wink_purchase_only, campaign.wink_purchase_status
        FROM merchant 
		left join campaign
		ON merchant.merchant_id = campaign.merchant_id
		left join wink_gate_campaign as wc
		ON campaign.campaign_id = wc.campaign_id
		WHERE campaign.wink_purchase_only =1 --wink_purchase_only=1
        AND campaign.campaign_status ='enable'
        AND Lower(campaign.wink_purchase_status)='on hold'
		AND (@campaign_name is null or  Lower(campaign.campaign_name)LIKE Lower('%'+ @campaign_name +'%') )
		AND (@advertiser_name is null or Lower(merchant.first_name + ' ' + merchant.last_name) LIKE Lower('%'+ @advertiser_name +'%') )
		AND (@campaign_id is null or campaign.campaign_id = @campaign_id)
		AND (@campaign_code is null or LOWER(campaign.campaign_code) like  Lower('%'+ @campaign_code +'%'))
		ORDER BY campaign.campaign_id DESC
	END
	ELSE IF (@status='activate')
	BEGIN
		SELECT campaign.campaign_id, campaign.campaign_name, 
		merchant.first_name,merchant.last_name,
		campaign.campaign_code,
		campaign.campaign_amount, campaign.total_winks, campaign.total_winks_amount,  
		wc.total_points as totalPoints,
		campaign.total_wink_confiscated,
		campaign.campaign_start_date, campaign.campaign_end_date,
		campaign.created_at,
		campaign.campaign_status,
		campaign.wink_purchase_only, campaign.wink_purchase_status
        FROM merchant 
		left join campaign
		ON merchant.merchant_id = campaign.merchant_id
		left join wink_gate_campaign as wc
		ON campaign.campaign_id = wc.campaign_id
		WHERE campaign.wink_purchase_only =1
        AND campaign.wink_purchase_only =1
        AND campaign.campaign_status ='enable'
        AND Lower(campaign.wink_purchase_status)='activate'
		AND (@campaign_name is null or  Lower(campaign.campaign_name)LIKE Lower('%'+ @campaign_name +'%') )
		AND (@advertiser_name is null or Lower(merchant.first_name + ' ' + merchant.last_name) LIKE Lower('%'+ @advertiser_name +'%') )
		AND (@campaign_id is null or campaign.campaign_id = @campaign_id)
		AND (@campaign_code is null or LOWER(campaign.campaign_code) like  Lower('%'+ @campaign_code +'%'))
		ORDER BY campaign.campaign_id DESC
	END
	ELSE IF (@status='disable')
	BEGIN
		SELECT campaign.campaign_id, campaign.campaign_name, 
		merchant.first_name,merchant.last_name,
		campaign.campaign_code,
		campaign.campaign_amount, campaign.total_winks, campaign.total_winks_amount,  
		wc.total_points as totalPoints,
		campaign.total_wink_confiscated,
		campaign.campaign_start_date, campaign.campaign_end_date,
		campaign.created_at,
		campaign.campaign_status,
		campaign.wink_purchase_only, campaign.wink_purchase_status
        FROM merchant 
		left join campaign
		ON merchant.merchant_id = campaign.merchant_id
		left join wink_gate_campaign as wc
		ON campaign.campaign_id = wc.campaign_id
		WHERE campaign.campaign_status ='disable'
		AND (@campaign_name is null or  Lower(campaign.campaign_name)LIKE Lower('%'+ @campaign_name +'%') )
		AND (@advertiser_name is null or Lower(merchant.first_name + ' ' + merchant.last_name) LIKE Lower('%'+ @advertiser_name +'%') )
		AND (@campaign_id is null or campaign.campaign_id = @campaign_id)
		AND (@campaign_code is null or LOWER(campaign.campaign_code) like  Lower('%'+ @campaign_code +'%'))
		ORDER BY campaign.campaign_id DESC
	END
END
