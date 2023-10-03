
CREATE PROCEDURE [dbo].[Get_Active_Promo_Banners]
AS
BEGIN

Declare @current_date datetime
EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date output

select TOP(1)* from promo_banner_ads_app as s where s.promo_banner_type = 'default'
and s.banner_image_status = 1

UNION
select * from promo_banner_ads_app as s where s.banner_image_status = 1
and cast(@current_date as date) >= cast(s.banner_from_date as date) 
and cast(@current_date as date) <= cast(s.banner_to_date as date)
order by id asc

END
