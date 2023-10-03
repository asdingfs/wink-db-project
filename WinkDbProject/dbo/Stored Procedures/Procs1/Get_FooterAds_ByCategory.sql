CREATE procedure [dbo].[Get_FooterAds_ByCategory]
(@category varchar(30))
AS
BEGIN
	Declare @current_date datetime
	EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date output

	if(@category='winktag')
	BEGIN
	select top 1 * from footer_ads_app as s where s.image_status =1 and winktag_status=1 
			and cast(@current_date as date) >= cast(s.from_date as date) 
			and redirect_to_winktag =0
			and cast(@current_date as date) <= cast(s.to_date as date) ORDER BY NEWID()
		
	END
	ELSE if(@category='winktreats')
	BEGIN
	select top 1 * from footer_ads_app as s where s.image_status =1 and winktreats_status=1 
			and cast(@current_date as date) >= cast(s.from_date as date) 
			and redirect_to_winktreats =0
			and cast(@current_date as date) <= cast(s.to_date as date) ORDER BY NEWID()
		
	END
	ELSE if (@category ='home')
	BEGIN
	select top 1 * from footer_ads_app as s where s.image_status =1 and home_status=1 
			and cast(@current_date as date) >= cast(s.from_date as date) 
			and cast(@current_date as date) <= cast(s.to_date as date) ORDER BY NEWID()
	END
	ELSE if (@category ='wink_contribute') /*1.wink_contribute*/
	BEGIN
	select top 1 * from footer_ads_app as s where s.image_status =1 
			and cast(@current_date as date) >= cast(s.from_date as date) 
			and cast(@current_date as date) <= cast(s.to_date as date) 
			and redirect_to_winktag =0
			and redirect_to_winktreats =0
			--and s.id=1000000
			ORDER BY NEWID()

	END
	ELSE if (@category ='wink_industry')/*2.wink_industry*/
	BEGIN
	select top 1 * from footer_ads_app as s where s.image_status =1 
			and cast(@current_date as date) >= cast(s.from_date as date) 
			and cast(@current_date as date) <= cast(s.to_date as date) 
			and redirect_to_winktag =0
			and redirect_to_winktreats =0
			--and s.id=1000000
			ORDER BY NEWID()
	END
	ELSE if (@category ='point_redemption')/*3.point_redemption*/
	BEGIN
	select top 1 * from footer_ads_app as s where s.image_status =1 
			and cast(@current_date as date) >= cast(s.from_date as date) 
			and cast(@current_date as date) <= cast(s.to_date as date) 
			and redirect_to_winktag =0
			and redirect_to_winktreats =0
			--and s.id=1000000
			ORDER BY NEWID()
	END
	ELSE if (@category ='point_redpt_summary')/*4.point_redpt_summary*/
	BEGIN
	select top 1 * from footer_ads_app as s where s.image_status =1 
			and cast(@current_date as date) >= cast(s.from_date as date) 
			and cast(@current_date as date) <= cast(s.to_date as date) 
			and redirect_to_winktag =0
			and redirect_to_winktreats =0
			--and s.id=1000000
			ORDER BY NEWID()
	END
	ELSE if (@category ='wink_redemption')/*5.wink_redemption*/
	BEGIN
	select top 1 * from footer_ads_app as s where s.image_status =1 
			and cast(@current_date as date) >= cast(s.from_date as date) 
			and cast(@current_date as date) <= cast(s.to_date as date) 
			and redirect_to_winktag =0
			and redirect_to_winktreats =0
			--and s.id=1000000
			ORDER BY NEWID()
	END

	ELSE if (@category ='wink_redpt_summary')/*6.wink_redpt_summary*/
	BEGIN
	select top 1 * from footer_ads_app as s where s.image_status =1 
			and cast(@current_date as date) >= cast(s.from_date as date) 
			and cast(@current_date as date) <= cast(s.to_date as date) 
			and redirect_to_winktag =0
			and redirect_to_winktreats =0
			--and s.id=1000000
			ORDER BY NEWID()
	END

	ELSE if (@category ='evoucher_redemption_home')/*7.evoucher_redemption_home*/
	BEGIN
	select top 1 * from footer_ads_app as s where s.image_status =1 
			and cast(@current_date as date) >= cast(s.from_date as date) 
			and cast(@current_date as date) <= cast(s.to_date as date) 
			and redirect_to_winktag =0
			and redirect_to_winktreats =0
			--and s.id=1000000
			ORDER BY NEWID()
	END

	ELSE if (@category ='evoucher_redept_branch_code')/*8.evoucher_redept_branch_code*/
	BEGIN
	select top 1 * from footer_ads_app as s where s.image_status =1 
			and cast(@current_date as date) >= cast(s.from_date as date) 
			and cast(@current_date as date) <= cast(s.to_date as date) 
			and redirect_to_winktag =0
			and redirect_to_winktreats =0
			--and s.id=1000000
			ORDER BY NEWID()
	END

	ELSE if (@category ='evoucher_redept_online')/*9.evoucher_redept_online*/
	BEGIN
	select top 1 * from footer_ads_app as s where s.image_status =1 
			and cast(@current_date as date) >= cast(s.from_date as date) 
			and cast(@current_date as date) <= cast(s.to_date as date) 
			and redirect_to_winktag =0
			and redirect_to_winktreats =0
			--and s.id=1000000
			ORDER BY NEWID()
	END

	ELSE if (@category ='avaiable_evoucher_list')/*10.avaiable_evoucher_list*/
	BEGIN
	select top 1 * from footer_ads_app as s where s.image_status =1 
			and cast(@current_date as date) >= cast(s.from_date as date) 
			and cast(@current_date as date) <= cast(s.to_date as date) 
			and redirect_to_winktag =0
			and redirect_to_winktreats =0
			--and s.id=1000000
			ORDER BY NEWID()
	END

	ELSE if (@category ='used_evoucher_list')/*11.used_evoucher_list*/
	BEGIN
	select top 1 * from footer_ads_app as s where s.image_status =1 
			and cast(@current_date as date) >= cast(s.from_date as date) 
			and cast(@current_date as date) <= cast(s.to_date as date) 
			and redirect_to_winktag =0
			and redirect_to_winktreats =0
			--and s.id=1000000
			ORDER BY NEWID()
	END

	ELSE if (@category ='nets_redpt_summary')/*12.nets_redpt_summary*/
	BEGIN
	select top 1 * from footer_ads_app as s where s.image_status =1 
			and cast(@current_date as date) >= cast(s.from_date as date) 
			and cast(@current_date as date) <= cast(s.to_date as date) 
			and redirect_to_winktag =0
			and redirect_to_winktreats =0
			--and s.id=1000000
			ORDER BY NEWID()
	END

	ELSE if (@category ='motoring')/*13.motoring*/
	BEGIN
	select top 1 * from footer_ads_app as s where s.image_status =1 
			and cast(@current_date as date) >= cast(s.from_date as date) 
			and cast(@current_date as date) <= cast(s.to_date as date) 
			and redirect_to_winktag =0
			and redirect_to_winktreats =0
			--and s.id=1000000
			ORDER BY NEWID()
	END

	ELSE if (@category ='points_campaign')/*14.points_campaign*/
	BEGIN
	select top 1 * from footer_ads_app as s where s.image_status =1 
			and cast(@current_date as date) >= cast(s.from_date as date) 
			and cast(@current_date as date) <= cast(s.to_date as date) 
			and redirect_to_winktag =0
			and redirect_to_winktreats =0
			--and s.id=1000000
			ORDER BY NEWID()
	END

	ELSE if (@category ='used_points')/*15.used_points*/
	BEGIN
	select top 1 * from footer_ads_app as s where s.image_status =1 
			and cast(@current_date as date) >= cast(s.from_date as date) 
			and cast(@current_date as date) <= cast(s.to_date as date) 
			and redirect_to_winktag =0
			and redirect_to_winktreats =0
			--and s.id=1000000
			ORDER BY NEWID()
	END

	ELSE if (@category ='wink_merchants_home')/*16.wink_merchants_home*/
	BEGIN
	select top 1 * from footer_ads_app as s where s.image_status =1 
			and cast(@current_date as date) >= cast(s.from_date as date) 
			and cast(@current_date as date) <= cast(s.to_date as date)
			and redirect_to_winktag =0
			and redirect_to_winktreats =0
			--and s.id=1000000
			 ORDER BY NEWID()
	END

	ELSE if (@category ='wink_merchants_industry')/*17.wink_merchants_industry*/
	BEGIN
	select top 1 * from footer_ads_app as s where s.image_status =1 
			and cast(@current_date as date) >= cast(s.from_date as date) 
			and cast(@current_date as date) <= cast(s.to_date as date) 
			and redirect_to_winktag =0
			and redirect_to_winktreats =0
			--and s.id=1000000
			ORDER BY NEWID()
	END

	ELSE if (@category ='wink_merchants')/*18.wink_merchants*/
	BEGIN
	select top 1 * from footer_ads_app as s where s.image_status =1 
			and cast(@current_date as date) >= cast(s.from_date as date) 
			and cast(@current_date as date) <= cast(s.to_date as date) 
			and redirect_to_winktag =0
			and redirect_to_winktreats =0
			--and s.id=1000000
			ORDER BY NEWID()
	END

	ELSE if (@category ='news_list')/*19.news_list*/
	BEGIN
	select top 1 * from footer_ads_app as s where s.image_status =1 
			and cast(@current_date as date) >= cast(s.from_date as date) 
			and cast(@current_date as date) <= cast(s.to_date as date) 
			and redirect_to_winktag =0
			and redirect_to_winktreats =0
			--and s.id=1000000
			ORDER BY NEWID()
		
	END

	ELSE if (@category ='news_detail')/*20.news_detail*/
	BEGIN
	select top 1 * from footer_ads_app as s where s.image_status =1 
			and cast(@current_date as date) >= cast(s.from_date as date) 
			and cast(@current_date as date) <= cast(s.to_date as date)
			and redirect_to_winktag =0
			and redirect_to_winktreats =0
			--and s.id=1000000
			 ORDER BY NEWID()
	END

	ELSE if (@category ='contact_us')/*21.contact_us*/
	BEGIN
	select top 1 * from footer_ads_app as s where s.image_status =1 
			and cast(@current_date as date) >= cast(s.from_date as date) 
			and cast(@current_date as date) <= cast(s.to_date as date) 
			and redirect_to_winktag =0
			and redirect_to_winktreats =0
			--and s.id=1000000
			ORDER BY NEWID()
	END
	ELSE if (@category ='points_campaign_summary')/*22.points_campaign_summary*/
	BEGIN
	select top 1 * from footer_ads_app as s where s.image_status =1 
			and cast(@current_date as date) >= cast(s.from_date as date) 
			and cast(@current_date as date) <= cast(s.to_date as date) 
			and redirect_to_winktag =0
			and redirect_to_winktreats =0
			--and s.id=1000000
			ORDER BY NEWID()
	END
	ELSE if (@category ='evoucher_verification_detail')/*23.evoucher_verification_detail*/
	BEGIN
	select top 1 * from footer_ads_app as s where s.image_status =1 
			and cast(@current_date as date) >= cast(s.from_date as date) 
			and cast(@current_date as date) <= cast(s.to_date as date) 
			and redirect_to_winktag =0
			and redirect_to_winktreats =0
			--and s.id=1000000
			ORDER BY NEWID()
	END
	ELSE if (@category ='evoucher_verification_summary')/*24.evoucher_verification_summary*/
	BEGIN
	select top 1 * from footer_ads_app as s where s.image_status =1 
			and cast(@current_date as date) >= cast(s.from_date as date) 
			and cast(@current_date as date) <= cast(s.to_date as date)
			and redirect_to_winktag =0 
			and redirect_to_winktreats =0
			--and s.id=1000000
			ORDER BY NEWID()
	END
	ELSE if (@category ='nets_redemption')/*25.nets_redemption*/
	BEGIN
	select top 1 * from footer_ads_app as s where s.image_status =1 
			and cast(@current_date as date) >= cast(s.from_date as date) 
			and redirect_to_winktag =0
			and redirect_to_winktreats =0
			and cast(@current_date as date) <= cast(s.to_date as date) ORDER BY NEWID()
	END
	ELSE 
	BEGIN
	select top 1 * from footer_ads_app as s where s.image_status =1
			and cast(@current_date as date) >= cast(s.from_date as date) 
			and redirect_to_winktag =0
			and redirect_to_winktreats =0
			and cast(@current_date as date) <= cast(s.to_date as date) ORDER BY NEWID()

	END


END


