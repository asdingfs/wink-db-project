CREATE PROC [dbo].[Get_Cohort_MAUChart_By_Month]
@year int

AS

BEGIN


select * from Cohort_MAU where year = @year


END

