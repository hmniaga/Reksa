
CREATE proc [dbo].[ReksaManualUpdateRiskProfile]
/*
	CREATED BY    : victor
	CREATION DATE : 
	DESCRIPTION   : 
	
	REVISED BY    :
	DATE, 	USER, 		PROJECT, 	NOTE
	-----------------------------------------------------------------------
	END REVISED
*/
@pcCIFNo									varchar (13),
@pdNewLastUpdate							datetime

as
set nocount on

declare @dNewLastUpdate						datetime
set @dNewLastUpdate = convert (datetime, convert (varchar, @pdNewLastUpdate, 112))

if not exists (select top 1 1 from dbo.ReksaRiskProfileLastUpdate_TM where convert (bigint, CIFNo) = convert (bigint, @pcCIFNo))
begin
	insert dbo.ReksaRiskProfileLastUpdate_TM (CIFNo, RiskProfileLastUpdate)
	select right (replicate ('0', 13) + @pcCIFNo, 13) 
											as CIFNo,
		@dNewLastUpdate						as RiskProfileLastUpdate
end
else
begin
	update dbo.ReksaRiskProfileLastUpdate_TM
	set RiskProfileLastUpdate = @dNewLastUpdate
	where convert (bigint, CIFNo) = convert (bigint, @pcCIFNo)
end


return 0
GO