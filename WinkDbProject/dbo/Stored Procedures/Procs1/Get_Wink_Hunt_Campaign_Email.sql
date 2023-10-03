-- Create the stored procedure in the specified schema
CREATE PROCEDURE [dbo].[Get_Wink_Hunt_Campaign_Email]
    @campaign_id int
AS
BEGIN
    -- body of the stored procedure
    SELECT TOP (1) [first_line], [title], [email_message]
    from wink_hunt_campaign_email
    where campaign_id = @campaign_id
END
