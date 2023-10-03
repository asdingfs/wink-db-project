CREATE procedure [dbo].[Get_FullPage_ByCategory]
(@category varchar(30))
AS
BEGIN
Declare @current_date datetime

EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date output

/******* fullpage category******/
/*
1.wink_contribute ( first page of Wink contribution)
2.wink_industry (second page of WINK , call by industry)
3.point_redemption (Point to WINK redemption page)
4.point_redpt_summary (Point to WINK redemption summary)
5.wink_redemption (Wink to eVoucher/ Nets)
6.wink_redpt_summary ( Wink to eVoucher summary)
7.evoucher_redemption_home ( After selecting eVoucher to redeem)
8.evoucher_redept_branch_code (Redeem eVoucher via branch code)
9.evoucher_redept_online (Redeem eVoucher via online)
10.avaiable_evoucher_list  (From my account)
11.used_evoucher_list (From my account)
12.nets_redpt_summary(From my account)
13.motoring (From my account)
14.points_campaign(From my account)
15.used_points(From my account)
16.wink_merchants_home (first page after clicking WINK merchant)
17.wink_merchants_industry (second page display by industry)
18.wink_merchants ( third page)
19.news_list 
20. news_detail
21.contact_us
22.points_campaign_summary
23. evoucher_verification_detail

23. evoucher_verification_summary
24.nets_redemption
 




*/


if(@category='winktag') 
BEGIN
select top 1 * from popup_ads_app as s where s.image_status =1 and winktag_status=1 
        and redirect_to_winktag =0
		and redirect_to_winktreats =0
        and cast(@current_date as date) >= cast(s.from_date as date) 
        and cast(@current_date as date) <= cast(s.to_date as date) ORDER BY NEWID()
END
ELSE if(@category='winktreats') 
BEGIN
select top 1 * from popup_ads_app as s where s.image_status =1 and winktreats_status=1 
        and redirect_to_winktag =0
		and redirect_to_winktreats =0
        and cast(@current_date as date) >= cast(s.from_date as date) 
        and cast(@current_date as date) <= cast(s.to_date as date) ORDER BY NEWID()
END
ELSE if (@category ='home')
BEGIN
	select top 1 * from popup_ads_app as s where s.image_status =1 and home_status=1 
        and cast(@current_date as date) >= cast(s.from_date as date) 
        and cast(@current_date as date) <= cast(s.to_date as date)
		--and s.id=1000000 -- during app submission 
		 ORDER BY NEWID()
		
END
ELSE if (@category ='wink_contribute') /*1.wink_contribute*/
BEGIN
select top 1 * from popup_ads_app as s where s.image_status =1 
        and cast(@current_date as date) >= cast(s.from_date as date) 
        and cast(@current_date as date) <= cast(s.to_date as date) 
		and redirect_to_winktag =0
		and redirect_to_winktreats = 0
		--and s.id=1000000
		ORDER BY NEWID()

END
ELSE if (@category ='wink_industry')/*2.wink_industry*/
BEGIN
select top 1 * from popup_ads_app as s where s.image_status =1 
        and cast(@current_date as date) >= cast(s.from_date as date) 
        and cast(@current_date as date) <= cast(s.to_date as date) 
		and redirect_to_winktag =0
		and redirect_to_winktreats = 0
		--and s.id=1000000
		ORDER BY NEWID()
END
ELSE if (@category ='point_redemption')/*3.point_redemption*/
BEGIN
select top 1 * from popup_ads_app as s where s.image_status =1 
        and cast(@current_date as date) >= cast(s.from_date as date) 
        and cast(@current_date as date) <= cast(s.to_date as date) 
		and redirect_to_winktag =0
		and redirect_to_winktreats = 0
		and s.id=1000000
		ORDER BY NEWID()
END
ELSE if (@category ='point_redpt_summary')/*4.point_redpt_summary*/
BEGIN
select top 1 * from popup_ads_app as s where s.image_status =1 
        and cast(@current_date as date) >= cast(s.from_date as date) 
        and cast(@current_date as date) <= cast(s.to_date as date) 
		and redirect_to_winktag =0
		and redirect_to_winktreats = 0
		and s.id=1000000
		ORDER BY NEWID()
END
ELSE if (@category ='wink_redemption')/*5.wink_redemption*/
BEGIN
select top 1 * from popup_ads_app as s where s.image_status =1 
        and cast(@current_date as date) >= cast(s.from_date as date) 
        and cast(@current_date as date) <= cast(s.to_date as date) 
		and redirect_to_winktag =0
		and redirect_to_winktreats = 0
		and s.id=1000000
		ORDER BY NEWID()
END

ELSE if (@category ='wink_redpt_summary')/*6.wink_redpt_summary*/
BEGIN
select top 1 * from popup_ads_app as s where s.image_status =1 
        and cast(@current_date as date) >= cast(s.from_date as date) 
        and cast(@current_date as date) <= cast(s.to_date as date) 
		and redirect_to_winktag =0
		and redirect_to_winktreats = 0
		and s.id=1000000
		ORDER BY NEWID()
END

ELSE if (@category ='evoucher_redemption_home')/*7.evoucher_redemption_home*/
BEGIN
select top 1 * from popup_ads_app as s where s.image_status =1 
        and cast(@current_date as date) >= cast(s.from_date as date) 
        and cast(@current_date as date) <= cast(s.to_date as date) 
		and redirect_to_winktag =0
		and redirect_to_winktreats = 0
		and s.id=1000000
		ORDER BY NEWID()
END

ELSE if (@category ='evoucher_redept_branch_code')/*8.evoucher_redept_branch_code*/
BEGIN
select top 1 * from popup_ads_app as s where s.image_status =1 
        and cast(@current_date as date) >= cast(s.from_date as date) 
        and cast(@current_date as date) <= cast(s.to_date as date) 
		and redirect_to_winktag =0
		and redirect_to_winktreats = 0
		and s.id=1000000
		ORDER BY NEWID()
END

ELSE if (@category ='evoucher_redept_online')/*9.evoucher_redept_online*/
BEGIN
select top 1 * from popup_ads_app as s where s.image_status =1 
        and cast(@current_date as date) >= cast(s.from_date as date) 
        and cast(@current_date as date) <= cast(s.to_date as date) 
		and redirect_to_winktag =0
		and redirect_to_winktreats = 0
		and s.id=1000000
		ORDER BY NEWID()
END

ELSE if (@category ='avaiable_evoucher_list')/*10.avaiable_evoucher_list*/
BEGIN
select top 1 * from popup_ads_app as s where s.image_status =1 
        and cast(@current_date as date) >= cast(s.from_date as date) 
        and cast(@current_date as date) <= cast(s.to_date as date) 
		and redirect_to_winktag =0
		and redirect_to_winktreats = 0
		--and s.id=1000000
		ORDER BY NEWID()
END

ELSE if (@category ='used_evoucher_list')/*11.used_evoucher_list*/
BEGIN
select top 1 * from popup_ads_app as s where s.image_status =1 
        and cast(@current_date as date) >= cast(s.from_date as date) 
        and cast(@current_date as date) <= cast(s.to_date as date) 
		--and s.id=1000000
		ORDER BY NEWID()
END

ELSE if (@category ='nets_redpt_summary')/*12.nets_redpt_summary*/
BEGIN
select top 1 * from popup_ads_app as s where s.image_status =1 
        and cast(@current_date as date) >= cast(s.from_date as date) 
        and cast(@current_date as date) <= cast(s.to_date as date) 
		and redirect_to_winktag =0
		and redirect_to_winktreats = 0
		--and s.id=1000000
		ORDER BY NEWID()
END

ELSE if (@category ='motoring')/*13.motoring*/
BEGIN
select top 1 * from popup_ads_app as s where s.image_status =1 
        and cast(@current_date as date) >= cast(s.from_date as date) 
        and cast(@current_date as date) <= cast(s.to_date as date) 
		and redirect_to_winktag =0
		and redirect_to_winktreats = 0
		--and s.id=1000000
		ORDER BY NEWID()
END

ELSE if (@category ='points_campaign')/*14.points_campaign*/
BEGIN
select top 1 * from popup_ads_app as s where s.image_status =1 
        and cast(@current_date as date) >= cast(s.from_date as date) 
        and cast(@current_date as date) <= cast(s.to_date as date) 
		and redirect_to_winktag =0
		and redirect_to_winktreats = 0
		--and s.id=1000000
		ORDER BY NEWID()
END

ELSE if (@category ='used_points')/*15.used_points*/
BEGIN
select top 1 * from popup_ads_app as s where s.image_status =1 
        and cast(@current_date as date) >= cast(s.from_date as date) 
        and cast(@current_date as date) <= cast(s.to_date as date) 
		and redirect_to_winktag =0
		and redirect_to_winktreats = 0
		--and s.id=1000000
		ORDER BY NEWID()
END

ELSE if (@category ='wink_merchants_home')/*16.wink_merchants_home*/
BEGIN
select top 1 * from popup_ads_app as s where s.image_status =1 
        and cast(@current_date as date) >= cast(s.from_date as date) 
        and cast(@current_date as date) <= cast(s.to_date as date)
		and redirect_to_winktag =0
		and redirect_to_winktreats = 0
		and s.id=1000000
		 ORDER BY NEWID()
END

ELSE if (@category ='wink_merchants_industry')/*17.wink_merchants_industry*/
BEGIN
select top 1 * from popup_ads_app as s where s.image_status =1 
        and cast(@current_date as date) >= cast(s.from_date as date) 
        and cast(@current_date as date) <= cast(s.to_date as date) 
		and redirect_to_winktag =0
		and redirect_to_winktreats = 0
		--and s.id=1000000
		ORDER BY NEWID()
END

ELSE if (@category ='wink_merchants')/*18.wink_merchants*/
BEGIN
select top 1 * from popup_ads_app as s where s.image_status =1 
        and cast(@current_date as date) >= cast(s.from_date as date) 
        and cast(@current_date as date) <= cast(s.to_date as date)
		and redirect_to_winktag =0 
		and redirect_to_winktreats = 0
		and s.id=1000000
		ORDER BY NEWID()
END

ELSE if (@category ='news_list')/*19.news_list*/
BEGIN
select top 1 * from popup_ads_app as s where s.image_status =1 
        and cast(@current_date as date) >= cast(s.from_date as date) 
        and cast(@current_date as date) <= cast(s.to_date as date) 
		and redirect_to_winktag =0
		and redirect_to_winktreats = 0
		--and s.id=1000000
		ORDER BY NEWID()
		
END

ELSE if (@category ='news_detail')/*20.news_detail*/
BEGIN
select top 1 * from popup_ads_app as s where s.image_status =1 
        and cast(@current_date as date) >= cast(s.from_date as date) 
        and cast(@current_date as date) <= cast(s.to_date as date)
		and redirect_to_winktag =0
		and redirect_to_winktreats = 0
		--and s.id=1000000
		 ORDER BY NEWID()
END

ELSE if (@category ='contact_us')/*21.contact_us*/
BEGIN
select top 1 * from popup_ads_app as s where s.image_status =1 
        and cast(@current_date as date) >= cast(s.from_date as date) 
        and cast(@current_date as date) <= cast(s.to_date as date)
		and redirect_to_winktag =0 
		and redirect_to_winktreats = 0
		and s.id=1000000
		ORDER BY NEWID()
END
ELSE if (@category ='points_campaign_summary')/*22.points_campaign_summary*/
BEGIN
select top 1 * from popup_ads_app as s where s.image_status =1 
        and cast(@current_date as date) >= cast(s.from_date as date) 
        and cast(@current_date as date) <= cast(s.to_date as date) 
		and redirect_to_winktag =0
		and redirect_to_winktreats = 0
		and s.id=1000000
		ORDER BY NEWID()
END
ELSE if (@category ='evoucher_verification_detail')/*23.evoucher_verification_detail*/
BEGIN
select top 1 * from popup_ads_app as s where s.image_status =1 
        and cast(@current_date as date) >= cast(s.from_date as date) 
        and cast(@current_date as date) <= cast(s.to_date as date) 
		and redirect_to_winktag =0
		and redirect_to_winktreats = 0
		and s.id=1000000
		ORDER BY NEWID()
END
ELSE if (@category ='evoucher_verification_summary')/*24.evoucher_verification_summary*/
BEGIN
select top 1 * from popup_ads_app as s where s.image_status =1 
        and cast(@current_date as date) >= cast(s.from_date as date) 
        and cast(@current_date as date) <= cast(s.to_date as date)
		and redirect_to_winktag =0 
		and redirect_to_winktreats = 0
		and s.id=1000000
		ORDER BY NEWID()
END
ELSE if (@category ='nets_redemption')/*25.nets_redemption*/
BEGIN
select top 1 * from popup_ads_app as s where s.image_status =1 
        and cast(@current_date as date) >= cast(s.from_date as date) 
		and redirect_to_winktag =0
		and redirect_to_winktreats = 0
        and cast(@current_date as date) <= cast(s.to_date as date) ORDER BY NEWID()
END
ELSE 
BEGIN
select top 1 * from popup_ads_app as s where s.image_status =1
        and cast(@current_date as date) >= cast(s.from_date as date) 
		and redirect_to_winktag =0
		and redirect_to_winktreats = 0
        and cast(@current_date as date) <= cast(s.to_date as date) 
		and s.id=1000000 --- during app submission
		ORDER BY NEWID()
		
END


END


/*select * from wink_app_action

--update wink_app_action set action_status =1 where id 


select * from WINK_eVoucherConversion_Partner 

update WINK_eVoucherConversion_Partner set partner_status =1


select * from largebanner_ads_tracker order by created_at desc */


--select * from popup_ads_tracker order by created_at desc

--select * from popup_ads_app

--update popup_ads_app set home_status = 0 where id <=20


--select * from popup_ads_app
