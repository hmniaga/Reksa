CREATE proc [dbo].[ReksaUpdateOSApproval]  
/*  
 CREATED BY    : Oscar Marino  
 CREATION DATE : 20090508  
 DESCRIPTION   : Proses approve/reject data XML upload sinkronisasi OS Unit Balance  
   
 select * from ReksaOSUploadProcessLog_TH  
   
 ReksaOSUploadProcessLog_TH, Status   
  0 = baru upload  
  1 = approved  
  2 = rejected  
  3 = processed  
   
 exec ReksaUpdateOSApproval   
  @pnGuid = '9C228B93-6D66-475A-9378-30ED946990E6'  
  ,@pbAuth = 1  
  ,@pnNIK = 32622  
  ,@pbDebug = 1  
    
 select Status, * from ReksaOSUploadProcessLog_TH  
 where BatchGuid = '9C228B93-6D66-475A-9378-30ED946990E6'  
   
 update  ReksaOSUploadProcessLog_TH  
 set Status = 0  
 where BatchGuid = '9C228B93-6D66-475A-9378-30ED946990E6'  
  
 REVISED BY    :  
  DATE,  USER,   PROJECT,  NOTE  
  -----------------------------------------------------------------------  
  20100203, oscar, REKSADN014, hapus pengecekan data existing  
  20120824, liliana, BAALN11003, hitung maintenance fee  
  20120831, liliana, BAALN11003, sinkronisasi akan efektif setelah otorisasi  
  20121008, liliana, BAALN11003, maintenance fee pindah lagi ke EOD  
  20140313, liliana, LIBST13021, pengecekan ketika eod
 END REVISED  
*/  
 @pnGuid  uniqueidentifier,  
 @pbAuth  bit = 0,  
 @pnNIK  int,  
 @pbDebug bit = 0  
as  
set nocount on  
  
declare   
 @nOK  tinyint,  
 @cErrMsg varchar(100)  
--20120824, liliana, BAALN11003, begin  
 ,@dValueDate datetime  
 ,@dCustodyId    int  
--20120824, liliana, BAALN11003, end  
--20140313, liliana, LIBST13021, begin  
 ,@dCurrDate  datetime  
 ,@dCurrWorkingDate datetime  
--20140313, liliana, LIBST13021, end  
  
set @nOK = 0  
  
-- validasi parameter  
if not exists (select top 1 1 from ReksaOSUploadProcessLog_TH  
 where BatchGuid = @pnGuid)  
begin  
 set @cErrMsg = 'Batch ' + convert(varchar(50), @pnGuid) + ' tidak ditemukan'  
 goto ERR_HANDLER  
end  
--20121008, liliana, BAALN11003, begin  
--cek apakah sedang EOD atau tidak  
if exists(select top 1 1 from dbo.control_table where end_of_day = 1 and begin_of_day = 0)            
begin            
 set @cErrMsg = 'Sedang proses EOD, harap menunggu sebentar dan login kembali'            
 goto ERR_HANDLER            
end  
--20121008, liliana, BAALN11003, end  
--20140313, liliana, LIBST13021, begin  
select @dCurrDate = current_working_date  
from control_table  
  
select @dCurrWorkingDate = current_working_date  
from dbo.fnGetWorkingDate()  
  
if @dCurrDate < @dCurrWorkingDate  
begin            
  set @cErrMsg = 'Sedang proses EOD, harap menunggu sebentar dan login kembali'            
  goto ERR_HANDLER            
end  
  
if @dCurrDate = @dCurrWorkingDate  
 and exists(select top 1 1 from dbo.process_table where stored_procedure_name = 'ReksaProcessEODEOM' and success_bit = 0)  
begin            
  set @cErrMsg = 'Sedang proses EOD, harap menunggu sebentar dan login kembali'            
  goto ERR_HANDLER            
end  
--20140313, liliana, LIBST13021, end  
  
-- yg sudah pernah ditolak  
if exists (select top 1 1 from ReksaOSUploadProcessLog_TH  
 where BatchGuid = @pnGuid and [Status] = 2)  
begin  
 set @cErrMsg = 'Batch ' + convert(varchar(50), @pnGuid) + ' sudah pernah ditolak'  
 goto ERR_HANDLER  
end  
  
-- yg sudah pernah dijalankan  
if exists (select top 1 1 from ReksaOSUploadProcessLog_TH  
 where BatchGuid = @pnGuid and [Status] = 3)  
begin  
 set @cErrMsg = 'Batch ' + convert(varchar(50), @pnGuid) + ' sudah pernah dijalankan'  
 goto ERR_HANDLER  
end  
  
--20100203, oscar, REKSADN014, begin  
---- kl ada data yg blm jalan, ga bole otor dulu  
--if exists (select top 1 1 from ReksaOSUploadProcessLog_TH where Status = 1)  
--begin  
-- set @cErrMsg = 'Masih ada data upload yang belum dijalankan'  
-- goto ERR_HANDLER  
--end   
--20100203, oscar, REKSADN014, end  
  
-- update status  
begin tran  
  
update ReksaOSUploadProcessLog_TH  
set [Status] = case @pbAuth  
     when 0 then 2   
     else 1   
    end, -- Status 1 = approved, 2 = reject  
 LastUpdate = getdate(),  
 Supervisor = @pnNIK  
where BatchGuid = @pnGuid  
  
if @@error <> 0  
begin  
 set @cErrMsg = 'Gagal otorisasi data upload, batch Guid = ' + convert(varchar(50), @pnGuid)  
 rollback tran  
 goto ERR_HANDLER  
end  
  
--if @pbAuth = 1 -- approve, maka lgs diproses saja  
--begin  
-- exec @nOK = ReksaUpdateOSProcess @pnGuid  
-- if @nOK <> 0 or @@error <> 0  
-- begin  
--  set @cErrMsg = 'Gagal proses data upload, batch Guid = ' + convert(varchar(50), @pnGuid)   
--  rollback tran  
--  goto ERR_HANDLER  
-- end  
--end  
--20120824, liliana, BAALN11003, begin  
if @pbAuth = 1 -- approve  
begin  
--20120831, liliana, BAALN11003, begin  
 exec @nOK = ReksaUpdateOSProcess @pnGuid  
 if @nOK <> 0 or @@error <> 0  
 begin  
  set @cErrMsg = 'Gagal proses data upload, batch Guid = ' + convert(varchar(50), @pnGuid)   
  rollback tran  
  goto ERR_HANDLER  
 end  
--20120831, liliana, BAALN11003, end  
--20121008, liliana, BAALN11003, begin  
 --select @dValueDate = NAVValueDate, @dCustodyId = CustodyId   
 --from dbo.ReksaOSUploadProcessLog_TH  
 --where BatchGuid = @pnGuid  
  
 --exec @nOK = ReksaProcessMFeeByOSUnit @dValueDate, @pnGuid, @dCustodyId, @pbDebug  
 --if @nOK <> 0 or @@error <> 0  
 --begin  
 -- set @cErrMsg = 'Proses process maintenance fee gagal, batch Guid = ' + convert(varchar(50), @pnGuid)   
 -- rollback tran  
 -- goto ERR_HANDLER  
 --end  
--20121008, liliana, BAALN11003, end  
  
end  
--20121008, liliana, BAALN11003, begin  
--20121008, liliana, BAALN11003, end  
  
commit tran  
  
ERR_HANDLER:  
if isnull(@cErrMsg, '') <> ''  
begin  
 raiserror (@cErrMsg  ,16,1)
 set @nOK = 1  
end  
  
return @nOK
GO