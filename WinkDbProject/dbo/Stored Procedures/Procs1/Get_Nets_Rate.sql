CREATE PROCEDURE [dbo].[Get_Nets_Rate]
AS 


BEGIN

DECLARE @TEMP_NETs_Normal_Rate TABLE (
							
	Normal_nets_rate decimal(10, 2) NULL
								)

DECLARE @TEMP_NETs_Promotion_Rate TABLE (
							
	Promotion_nets_rate decimal(10, 2) NULL,
	Promotion_start datetime NULL,
	Promotion_end datetime NULL
								)

DECLARE @TEMP_NETs_Sponsor TABLE (
							
	Total_sponsor_points decimal NULL,	
	Sponsor_start datetime NULL,
	Sponsor_end datetime NULL
								)

DECLARE @TEMP_NETs_Rate TABLE (
							

	Normal_nets_rate decimal(10, 2) NULL,
	Promotion_nets_rate decimal(10, 2) NULL,
	Promotion_start datetime NULL,
	Promotion_end datetime NULL,

	Total_sponsor_points decimal NULL,	
	Sponsor_start datetime NULL,
	Sponsor_end datetime NULL

	)


INSERT INTO @TEMP_NETs_Normal_Rate
select rate_value As Normal_nets_rate from nets_rate_conversion where rate_code = 'nets_normal_points_per_tab'

INSERT INTO @TEMP_NETs_Promotion_Rate
select rate_value as Promotion_nets_rate, from_date as Promotion_start, to_date as Promotion_end  from nets_rate_conversion where rate_code = 'net_promo_per_tab'

INSERT INTO @TEMP_NETs_Sponsor
select total_points as Total_sponsor_points , from_date as Sponsor_start, to_date as Sponsor_end from nets_sponsor_points



INSERT INTO @TEMP_NETs_Rate
select * from @TEMP_NETs_Normal_Rate, @TEMP_NETs_Promotion_Rate, @TEMP_NETs_Sponsor



select * from @TEMP_NETs_Rate

END 

