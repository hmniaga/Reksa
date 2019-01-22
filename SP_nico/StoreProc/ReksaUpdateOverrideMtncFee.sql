CREATE proc [dbo].[ReksaUpdateOverrideMtncFee]
/*
	CREATED BY    : liliana
	CREATION DATE : 20110928
	DESCRIPTION   : 
	REVISED BY    :
		DATE,		USER, 	PROJECT, 	NOTE
		-----------------------------------------------------------------------

	END REVISED
	
	TESTCODE :
	END TESTCODE
	
	NOTE :
	END NOTE
*/
@pnNIK									int,
@pcModule								varchar(20),
@pcErrMsg								varchar(100)	output,
@pcGuid									uniqueidentifier,
@pnAgentId								int,
@pmOverridenMaintenanceFee				money

as

set nocount on

declare @nErrNo							int,
	@dNow								datetime

exec dbo.set_raiserror @@procid, @nErrNo output

update dbo.ReksaOverrideMtncFeeDetail_TM
set OverridenMaintenanceFee = @pmOverridenMaintenanceFee
where [Guid] = @pcGuid
	and AgentId = @pnAgentId

return 0

errorhandler:
if @@trancount > 0
begin
	rollback tran
end
raiserror (@pcErrMsg,16,1)
return 1
GO