CREATE PROCEDURE  [dbo].[CreateNewCampagin] 
(
@campaign_id int out,
@merchant_id int,
@campaign_name varchar(255),
@campaign_code varchar(255),
@campaign_amount Decimal(10,2),
@cents_per_wink Decimal(10,2),
@percent_for_wink Decimal(10,2),
@sales_code varchar(255),
@sales_commission Decimal(10,2),
@total_winks int,
@total_winks_amount Decimal(10,2),
@agency bit,
@agency_name varchar(255),
@campaign_start_date DateTime,
@campaign_end_date DateTime,
@created_at DateTime,
@updated_at DateTime
)
AS
BEGIN 
DECLARE @current_date datetime
DECLARE @maxID int
DECLARE @agency_comm decimal(10,2)
--DECLARE @sales_comm decimal(10,2)
DECLARE @7di_comm decimal(10,2)
SET @agency_comm =0
SET @sales_commission =0
IF @agency = 1
	BEGIN
Set @agency_comm = ISNULL( (Select system_key_value.system_value from system_key_value where system_key_value.system_key = 'agency_com'),0)
	END
IF @sales_code !='' AND @sales_code IS NOT NULL
	BEGIN
Set @sales_commission = ISNULL( (Select system_key_value.system_value from system_key_value where system_key_value.system_key = 'sales_com'),0)
	END

Set @7di_comm = ISNULL( (Select system_key_value.system_value from system_key_value where system_key_value.system_key = '7di'),0)

EXEC GET_CURRENT_SINGAPORT_DATETIME @current_date OUTPUT
INSERT INTO campaign
           ([merchant_id]
           ,[campaign_name]
           ,[campaign_code]
           ,[campaign_amount]
           ,[cents_per_wink]
           ,[percent_for_wink]
           ,[sales_code]
           ,[sales_commission]
           ,[revenue_share]
           ,[agency_comm]
           ,[total_winks]
           ,[total_winks_amount]
           ,[agency]
           ,[agency_name]
           ,[campaign_start_date]
           ,[campaign_end_date]
           ,[created_at]
           ,[updated_at])
     VALUES
           (@merchant_id
           ,@campaign_name
           ,@campaign_code
           ,@campaign_amount
           ,@cents_per_wink
           ,@percent_for_wink
           ,@sales_code
           ,@sales_commission
           ,@7di_comm
           ,@agency_comm
           ,@total_winks
           ,@total_winks_amount
           ,@agency
           ,@agency_name
           ,@campaign_start_date
           ,@campaign_end_date
           ,@current_date
           ,@current_date);
          SET @maxID = (SELECT @@IDENTITY);
     
     IF (@maxID > 0)
     BEGIN
      SET @campaign_id  =  (SELECT SCOPE_IDENTITY());
         END   
     
 
END

--update campaign set revenue_share = 20 


--update campaign set sales_commission=1 where campaign.sales_code!=''


--update campaign set agency_comm=15 where agency =1
--select * from campaign order by campaign.campaign_id desc
--select * from system_key_value
--update system_key_value set system_value =1 where id=7
