
CREATE proc [dbo].[ReksaPopulateParameterWS]
/*
	CREATED BY    : victor
	CREATION DATE : 
	DESCRIPTION   : 
	REVISED BY    :
		DATE, 	USER, 		PROJECT, 	NOTE
		-----------------------------------------------------------------------
		20120131, eric, BAEIT12001, TIBCOParamTable_TR diambil dari SQL_REPLICATE
	END REVISED
	
	declare @a varchar(30), @b varchar(10)
	exec dbo.ReksaPopulateParameterWS null, null, null, 'TRX_Create_RTGS', @a output, @b output
	select @a, @b
*/
@pnNIK									int,
@pcModule								varchar(25),
@pcErrMsg								varchar(100)	output,
@pcServiceName							varchar(100),
@pcIP									varchar(30)		output,
@pcPort									varchar(10)		output

as

set nocount on

select @pcIP = TIBCOIPAddress, @pcPort = TIBCOPort
--20120131, eric, BAEIT12001, begin
--from SQL_SOA.dbo.TIBCOParamTable_TM
--20120131, eric, BAEIT12001, begin
from TIBCOParamTable_TM_v
--20120131, eric, BAEIT12001, end
--20120131, eric, BAEIT12001, end
where ServiceName = @pcServiceName

return 0
GO