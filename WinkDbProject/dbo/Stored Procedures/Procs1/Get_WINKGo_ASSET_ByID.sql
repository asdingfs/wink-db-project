CREATE PROCEDURE [dbo].[Get_WINKGo_ASSET_ByID]
(
	@id int
)
AS
BEGIN

  Declare @campaign_id int

  IF EXISTS (SELECT 1 from ASSET_WINKGO where id=@id)
  BEGIN
	select  @campaign_id = campaign_id from ASSET_WINKGO where id=@id
      select [id], [name],[image], [url], [campaign_id], [points], [interval],
	 [status],[created_at], [from_date], [to_date], [updated_at]
	,CASE WHEN EXISTS (select 1 from ASSET_WINKGO where id!=@id  
						and campaign_id=@campaign_id and [status]='1') then '1' ELSE '0' END AS booked_status
	from ASSET_WINKGO where id = @id
  END

 END  


