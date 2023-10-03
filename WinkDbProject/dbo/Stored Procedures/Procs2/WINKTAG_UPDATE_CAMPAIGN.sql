CREATE PROCEDURE  [dbo].[WINKTAG_UPDATE_CAMPAIGN] 
(
    @WTcampaign_id int,
    @campaign_name varchar(100),
	@points int,
	@content varchar(100),
	@winktag_type  varchar(100),
	@position int,
	@winktag_report varchar(100),
	@size int,
	@limit int,
	@campaign_image_large varchar(200),
	@campaign_image_small varchar(200),
 
	@from_date varchar(50),
	@to_date varchar(50)
   
	 
)
AS
BEGIN 
DECLARE @current_date datetime
EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date OUTPUT
if(@from_date ='')
set @from_date=null
if(@to_date='')
set @to_date=null

Update winktag_campaign set  campaign_name=@campaign_name,
campaign_image_large=@campaign_image_large,
campaign_image_small=@campaign_image_small,
points = @points,
content =@content,
winktag_type=@winktag_type,
position=@position,
updated_at=@current_date,
winktag_report=@winktag_report,
size = @size,
limit=@limit,
from_date= @from_date,
to_date= @to_date 
where campaign_id = @WTcampaign_id

If(@@ROWCOUNT>0)
select '1' as response_code , 'Successfully updated' as response_message
Else 
select '0' as response_code , 'Fail to update' as response_message

 
END
