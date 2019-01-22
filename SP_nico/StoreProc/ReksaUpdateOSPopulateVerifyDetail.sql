CREATE proc [dbo].[ReksaUpdateOSPopulateVerifyDetail]
/*
	CREATED BY    : liliana
	CREATION DATE : 20110906
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
select ClientCode							as ClientCode,
	UnitBalanceBefore						as OutstandingUnitProReksa,
	UnitBalanceAfter						as OutstandingUnitBankCustody,
	isnull (UnitBalanceBefore, 0) - isnull (UnitBalanceAfter, 0)
											as Selisih
from dbo.ReksaOSUploadLog_TH 
where BatchGuid = @puBatchGuid
	and isnull (UnitBalanceBefore, 0) - isnull (UnitBalanceAfter, 0) != 0			--tampilkan hanya yang ada selisih

return 0

errorhandler:
if @@trancount > 0
begin
	rollback tran
end
raiserror (@cErrorMessage,16,1)
return 1
GO