-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE PROCEDURE [dbo].[Winktag_age_verification]
	-- Add the parameters for the stored procedure here
	@customer_id int,
	@min_age int,
	@max_age int

AS
BEGIN
	Declare @customer_age int
	Set @customer_age = 
	(
	Select floor(datediff(day,c.date_of_birth, DATEADD(HOUR,8,GETDATE())) / 365.25) as age 
	from customer c
	WHERE c.customer_id = @customer_id 
	)

	IF( (@customer_age < @min_age)  or (@customer_age > @max_age))
		return 0
	ELSE 
		return 1
		

END

	
