CREATE proc [dbo].[ReksaUpdateMFeePopulateVerifyDetail]
/*
	CREATED BY    : liliana
	CREATION DATE : 20120611
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
select 
	rm.TanggalTransaksi						as TanggalTransaksi,
	rm.ReverseTanggalTransaksi				as ReverseTanggalTransaksi,
	rc.ClientCode							as ClientCode,
	rm.NominalMaintenanceFeeBefore			as NominalMaintenanceFeeBefore,
	rm.NominalMaintenanceFeeAfter			as NominalMaintenanceFeeAfter,
	isnull (rm.NominalMaintenanceFeeBefore, 0) - isnull (rm.NominalMaintenanceFeeAfter, 0)
											as Selisih
from dbo.ReksaMFeeUploadLog_TH rm
	join dbo.ReksaCIFData_TM rc
	on rm.ClientId = rc.ClientId
where rm.BatchGuid = @puBatchGuid
	and isnull (rm.NominalMaintenanceFeeBefore, 0) - isnull (rm.NominalMaintenanceFeeAfter, 0) != 0			--tampilkan hanya yang ada selisih


return 0

errorhandler:
if @@trancount > 0
begin
	rollback tran
end
raiserror (@cErrorMessage,16,1)
return 1
GO