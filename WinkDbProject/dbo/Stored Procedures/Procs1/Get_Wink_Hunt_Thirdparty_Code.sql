-- Create the stored procedure in the specified schema
CREATE PROCEDURE [dbo].[Get_Wink_Hunt_Thirdparty_Code]
    @campaign_id int
AS
BEGIN
    SELECT TOP (1) [game_code] as code
    from wink_hunt_thirdparty_code
    where campaign_id = @campaign_id
    AND used_status = 0;
END
