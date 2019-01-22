CREATE proc [dbo].[ReksaProcessAdhoc]
/*  
 CREATED BY    : Anthony  
 CREATION DATE : 20100126  
 DESCRIPTION   : Proses adhoc sinkronisasi NAV, Trx dan OS Unit
 REVISED BY    :  
  DATE,  USER,   PROJECT,  NOTE  
  -----------------------------------------------------------------------  
  20100126, anthony, REKSADN014, ubah pesan error
  20100203, oscar, REKSADN014, update ProcessStatus
  20100209, oscar, REKSADN014, saat error tidak perlu update ProcessStatus
  20100319, oscar, REKSADN014, update process status = 0 saat selesai
  20120710, liliana, BAALN11003, tambah utk sinkronisasi maintenance fee
 END REVISED  
*/  
	@pnProcessId int,
	@pnNIK int,
	@pcGuid uniqueidentifier
as
set nocount on
declare
   @nOK int
	, @cErrMsg varchar(255)
	
set @nOK = 0
  
If exists(select top 1 1 from ReksaUserProcess_TR where ProcessId = @pnProcessId and LastUser is not Null)
	set @cErrMsg = 'Sedang dijalankan oleh user lain'
else If exists(select top 1 1 from ReksaUserProcess_TR where ProcessId = @pnProcessId and ProcessStatus = 1)
	set @cErrMsg = 'Sudah dijalankan hari ini'

If isnull(@cErrMsg,'') != ''
	goto ERR_HANDLER

-- tag dulu biar ngga diproses ama user lain
Update ReksaUserProcess_TR
set LastUser = @pnNIK
 , PrevLastRun = LastRun
 , LastRun = getdate()
--20100203, oscar, REKSADN014, begin
--20100209, oscar, REKSADN014, begin   
 --, ProcessStatus = 1
--20100209, oscar, REKSADN014, end
--20100203, oscar, REKSADN014, end 
where ProcessId = @pnProcessId

--1. dbo.ReksaUpdateProdNAVProcessAll @pbAdHoc = 1
exec @nOK = ReksaUpdateProdNAVProcessAll @pnNIK, 1
if @nOK <> 0 or @@error <> 0
begin
   set @cErrMsg = 'Gagal sinkronisasi NAV'
   goto ERR_HANDLER
end

--2. dbo.ReksaUpdateTrxProcess @pbAdHoc = 1
exec @nOK = ReksaUpdateTrxProcess 1
if @nOK <> 0 or @@error <> 0
begin
   set @cErrMsg = 'Gagal sinkronisasi transaksi'
   goto ERR_HANDLER
end

--3. dbo.ReksaUpdateOSProcessAll @pbAdHoc = 1
exec @nOK = ReksaUpdateOSProcessAll 1
if @nOK <> 0 or @@error <> 0
begin
--20100126, anthony, REKSADN014, begin
   --set @cErrMsg = 'Gagal sinkronisasi OS Unit'
   set @cErrMsg = 'Gagal sinkronisasi OS Unit.'
--20100126, anthony, REKSADN014, end
   goto ERR_HANDLER
end
--20120710, liliana, BAALN11003, begin

--4. dbo.ReksaUpdateMFeeProcessAll @pbAdHoc = 1
exec @nOK = ReksaUpdateMFeeProcessAll 1

if @nOK <> 0 or @@error <> 0
begin
   set @cErrMsg = 'Gagal sinkronisasi Maintenance Fee.'
   goto ERR_HANDLER
end
--20120710, liliana, BAALN11003, end

-- sudah selesai, lepas tag  
Update ReksaUserProcess_TR
set LastUser = NULL
--20100209, oscar, REKSADN014, begin   
--20100319, oscar, REKSADN014, begin
 --, ProcessStatus = 1
 , ProcessStatus = 0
--20100319, oscar, REKSADN014, end
--20100209, oscar, REKSADN014, end
where ProcessId = @pnProcessId
  
If @@error != 0 or @@rowcount = 0
Begin
 set @cErrMsg = 'Gagal Release Tag Proses!'
 goto ERR_HANDLER
End

ERR_HANDLER:
if isnull(@cErrMsg, '') <> ''
begin
   -- sudah selesai, lepas tag  
   Update ReksaUserProcess_TR
   set LastUser = NULL
--20100209, oscar, REKSADN014, begin   
    --, ProcessStatus = 0
--20100209, oscar, REKSADN014, end    
   where ProcessId = @pnProcessId

   if @@trancount <> 0 rollback tran
	raiserror (@cErrMsg ,16,1);
	set @nOK = 1
end

return @nOK
GO