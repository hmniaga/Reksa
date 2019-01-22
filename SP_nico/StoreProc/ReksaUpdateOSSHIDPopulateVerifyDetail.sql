CREATE proc [dbo].[ReksaUpdateOSSHIDPopulateVerifyDetail]
/*
	CREATED BY    : liliana
	CREATION DATE : 20150606
	DESCRIPTION   : 
	REVISED BY    :
		DATE, 	USER, 		PROJECT, 	NOTE
		-----------------------------------------------------------------------

	END REVISED
	
*/
@puBatchGuid								uniqueidentifier

as

set nocount on

declare @nErrorNo							int,
	@cErrorMessage							varchar (100)

exec dbo.set_raiserror @@procid, @nErrorNo output

--select data detail
select ShareholderID							as ShareholderID,
	UnitBalanceBankCustody						as UnitBalanceBankCustody,
	ProductCode									as ProductCode,
	TranId										as TranId
from dbo.ReksaOSSHDIDUploadLog_TH 
where BatchGuid = @puBatchGuid

return 0

errorhandler:
if @@trancount > 0
begin
	rollback tran
end
raiserror (@cErrorMessage,16,1)
return 1
GO