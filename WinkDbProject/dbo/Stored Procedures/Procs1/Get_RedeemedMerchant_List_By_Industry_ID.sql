-- Create the stored procedure in the specified schema
CREATE PROCEDURE [dbo].[Get_RedeemedMerchant_List_By_Industry_ID]
    -- Input parameter
    @ID int
AS
BEGIN
    -- body of the stored procedure

    DECLARE @DefaultMessage VARCHAR(350)
    SET @DefaultMessage = 'Visit us at our store.'

    -- If description is null or empty, replace it to default message.
    SELECT merchant_id, name, merchant_logo_app, link_to_website_status, url, COALESCE(NULLIF(description,''),@DefaultMessage) as description
    from merchant_partners
    where industry_id = @id and status = 1
    order by merchant_partners.name ASC
END
