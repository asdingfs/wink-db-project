
Create function GetRandomString(@len int, @id uniqueidentifier)
returns varchar(255)
as
begin
 Declare @output varchar(255) 
 ---create string of random value with exact lenght you want
 Select @output  = substring(replace(@id  , '-',''), 2, @len+1)
 ---append a random LOWER Case letter
 Select @output  = CHAR(97 + datepart(hour, getdate())) + @output
 Select @output  = SUBSTRING(@output,0,@len)
 ---append a random Upper Case letter
 Select @output  =  @output + CHAR(90 - datepart(hour, getdate()))
 
  return @output
end
