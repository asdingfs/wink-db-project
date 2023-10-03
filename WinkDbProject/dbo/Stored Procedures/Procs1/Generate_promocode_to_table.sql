CREATE proc Generate_promocode_to_table
@prefix varchar(3),
@digit int,
@count int,
@points int,
@campaign_id int

AS
BEGIN
DECLARE @CURRENT_DATEtIME DATETIME
DECLARE @i AS int
DECLARE @promo_Code as varchar(15)
DECLARE @alphanumeric_code as varchar(10)

EXEC GET_CURRENT_SINGAPORT_DATETIME @CURRENT_DATETIME OUTPUT
--- check duplicate records in table before insert --
If not exists (select promo_code,count(*) as duplicate_count
from TBL_WINKPLAY_WINKHUNT_CODES
group by promo_code 
having count(*)>1)

SET @i=1
WHILE @i<=@count
	BEGIN
		SELECT @alphanumeric_code= cast(right(CONVERT(NVARCHAR(36), NEWID()), @digit) as varchar(15));
		SET @promo_Code = @prefix+right(@alphanumeric_code,@digit)
		--select @promo_Code
		INSERT INTO TBL_WINKPLAY_WINKHUNT_CODES (promo_code,wink_point_value,used_status,created_on,updated_on,campaign_id)
										  values(@promo_Code,@points,0,@CURRENT_DATEtIME,@CURRENT_DATEtIME,@campaign_id)
		SET @i=@i+1

	END
END

