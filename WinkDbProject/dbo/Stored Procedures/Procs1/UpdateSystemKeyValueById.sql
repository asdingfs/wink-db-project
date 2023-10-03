CREATE PROCEDURE UpdateSystemKeyValueById
	(@id int,
	 @system_value int
     )
AS
BEGIN

	DECLARE @RowUpdateCount int 
	Update system_key_value SET system_value = @system_value
    Where system_key_value.id = @id
    
    SET @RowUpdateCount = @@ROWCOUNT
    
    
 -- Check Scan Interval?
	
    IF @id =4 AND @RowUpdateCount >0
    BEGIN
	 Update asset_type_management SET scan_interval = @system_value
     RETURN 
    END
    ELSE IF @id =5 AND @RowUpdateCount >0 -- Check Scan Value?
    BEGIN
		Update asset_type_management SET scan_value = @system_value
     RETURN 
    END
	
END
